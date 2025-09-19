import torch
import torchvision.transforms as transforms
from torchvision import models
from PIL import Image

# API 사용
import requests
import json
import os
from dotenv import load_dotenv

# .env 파일에서 환경 변수 불러옴(API KEY)
load_dotenv()
USDA_API_KEY = os.getenv("USDA_API_KEY")
KOREAN_API_KEY = os.getenv("KOREAN_API_KEY")

if not USDA_API_KEY:
    raise ValueError("USDA API key not found. Please check your .env file.")
if not KOREAN_API_KEY:
    raise ValueError("Korean API key not found. Please check your .env file.")


# 한/미 API 관리
def get_usda_nutrition_info(food_name):
    # USDA API를 통해 영양 정보를 가져오는 함수(미국)
    search_url = f"https://api.nal.usda.gov/fdc/v1/foods/search?api_key={USDA_API_KEY}&query={food_name}"
    
    try:
        response = requests.get(search_url)
        response.raise_for_status()
        search_results = response.json()
        
        if not search_results.get('foods'):
            return None
        
        fdc_id = search_results['foods'][0]['fdcId']
        food_details_url = f"https://api.nal.usda.gov/fdc/v1/food/{fdc_id}?api_key={USDA_API_KEY}"
        details_response = requests.get(food_details_url)
        details_response.raise_for_status()
        food_details = details_response.json()
        
        nutrition_data = {}
        nutrients = food_details.get('foodNutrients', [])
        for nutrient in nutrients:
            name = nutrient['nutrient']['name']
            value = nutrient['amount']
            unit = nutrient['nutrient']['unitName']
            if name in ['Energy', 'Protein', 'Total lipid (fat)', 'Carbohydrate, by difference']:
                nutrition_data[name] = f"{value} {unit}"
                
        return nutrition_data
    
    except (requests.exceptions.RequestException, KeyError):
        return None

# 식약처 API를 통해 영양 정보를 가져오는 함수(한국)
def get_korean_nutrition_info(food_name):
    api_url = f"http://openapi.foodsafetykorea.go.kr/api/{KOREAN_API_KEY}/I2790/json/1/100/DESC_KOR={food_name}"
    
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        data = response.json()
        
        if data.get('I2790', {}).get('RESULT', {}).get('MSG_CODE') != 'INFO-000':
            return None
            
        item = data['I2790']['row'][0]
        nutrition_data = {
            '에너지(Kcal)': f"{item['NUTR_CONT1']} kcal",
            '단백질(g)': f"{item['NUTR_CONT2']} g",
            '지방(g)': f"{item['NUTR_CONT3']} g",
            '탄수화물(g)': f"{item['NUTR_CONT4']} g",
        }
        return nutrition_data
        
    except (requests.exceptions.RequestException, KeyError, IndexError):
        return None

# 메인 영양정보 함수
def get_nutrition_info(food_name):
    # Food-101 데이터셋의 클래스 이름과 한국 음식을 매핑
    korean_food_list = ['김치찌개', '비빔밥', '불고기', '된장찌개', '잡채'] # 예시 리스트, 실제 데이터셋에 맞춰 수정 필요
    
    if food_name in korean_food_list:
        print(f"'{food_name}'은(는) 한국 음식으로 식약처 API를 호출합니다.")
        nutrition = get_korean_nutrition_info(food_name)
        if nutrition:
            return nutrition
        else:
            print("식약처 API에서 데이터를 찾을 수 없습니다. USDA API를 시도합니다.")
            return get_usda_nutrition_info(food_name)
    else:
        print(f"'{food_name}'은(는) 미국 음식으로 USDA API를 호출합니다.")
        return get_usda_nutrition_info(food_name)


# 모델 및 이미지 처리
with open('food101_classes.txt', 'r') as f:
    class_names = [line.strip() for line in f.readlines()]

model = models.resnet50(weights=None)
model.fc = torch.nn.Sequential(
    torch.nn.Dropout(p=0.5),
    torch.nn.Linear(model.fc.in_features, 101)
)
checkpoint = torch.load("food101_model.pth", map_location=torch.device('cpu'))
model.load_state_dict(checkpoint['model_state_dict'])
model.eval()

class_names = checkpoint['idx_to_class']

transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406], 
        std=[0.229, 0.224, 0.225]
    )
])


def predict_image(image_path):
    image = Image.open(image_path).convert("RGB")
    input_tensor = transform(image).unsqueeze(0)

    with torch.no_grad():
        output = model(input_tensor)
        _, predicted = torch.max(output, 1)
    
    predicted_class = class_names[predicted.item()]
    print("Predicted food:", predicted_class)
    
    nutrition_info = get_nutrition_info(predicted_class)
    
    if nutrition_info:
        print("Nutritional Information:")
        for key, value in nutrition_info.items():
            print(f"- {key}: {value}")
    else:
        print("Nutritional info not available.")
    
# 예시 사용
predict_image("img/sushi.jpg")