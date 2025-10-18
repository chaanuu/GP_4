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

if not USDA_API_KEY:
    raise ValueError("USDA API key not found. Please check your .env file.")

def get_usda_nutrition_info(food_name):
    # USDA API를 통해 영양 정보를 가져오는 함수
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

# 메인 영양정보 함수
def get_nutrition_info(food_name):
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
    
    if not nutrition_info and '_' in predicted_class:
        search_words = predicted_class.split('_')
        last_word = search_words[-1]
        
        print(f"Nutritional info not found for '{predicted_class}'. Retrying with the last word: '{last_word}'...")
        nutrition_info = get_nutrition_info(last_word)
    
    if nutrition_info:
        ORDER = ['Energy', 'Protein', 'Total lipid (fat)', 'Carbohydrate, by difference']
        
        print("\nNutritional Information:")
        for key in ORDER:
            value = nutrition_info.get(key)
            if value:
                display_key = 'Fat' if key == 'Total lipid (fat)' else key
                print(f"- {display_key}: {value}")
            else:
                print(f"- {key}: N/A")
    else:
        print("Nutritional info not available after all attempts.\n")

    user_ans = input("Is the result correct?(y/n) ")
    if user_ans.lower() == 'n':
        user_foodname = input("Would you like to type the name of the food manually? ").lower()
        
        manual_nutrition_info = get_nutrition_info(user_foodname)

        if manual_nutrition_info:
            print(f"\nNutritional Information for '{user_foodname}':")
            for key, value in manual_nutrition_info.items():
                print(f"- {key}: {value}")
        else:
            print(f"\nSorry, nutritional info for '{user_foodname}' is not available in the database.")
            
# 예시 사용
predict_image("img/sandwich.jpg")