import torch
import torchvision.transforms as transforms
from torchvision import models
from PIL import Image

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
    """USDA API를 통해 영양 정보를 가져오는 함수 (미국)"""
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
            # 주요 영양소만 추출하여 저장 (단위를 포함)
            if name in ['Energy', 'Protein', 'Total lipid (fat)', 'Carbohydrate, by difference']:
                nutrition_data[name] = f"{value} {unit}"

        return nutrition_data

    except (requests.exceptions.RequestException, KeyError, IndexError):
        return None

# 메인 영양정보 함수
def get_nutrition_info(food_name):
    """현재는 USDA API만 사용"""
    return get_usda_nutrition_info(food_name)

# --- 모델 로드 및 변환 (이하 동일) ---
# NOTE: 이 파일은 실제 Express 컨트롤러에서 모듈로 임포트되어 사용된다고 가정합니다.

# food101_classes.txt 파일 경로가 올바른지 확인 필요
with open('food101_classes.txt', 'r') as f:
    class_names = [line.strip() for line in f.readlines()]

model = models.resnet50(weights=None)
model.fc = torch.nn.Sequential(
    torch.nn.Dropout(p=0.5),
    torch.nn.Linear(model.fc.in_features, 101)
)
# food101_model.pth 파일 경로가 올바른지 확인 필요
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
    """
    이미지를 분석하고, 영양 정보를 조회한 후, 결과를 딕셔너리 형태로 반환합니다.
    (Express 서버에서 JSON으로 변환될 수 있도록 구성)
    """
    try:
        image = Image.open(image_path).convert("RGB")
    except FileNotFoundError:
        return {'error': 'Image file not found.'}

    input_tensor = transform(image).unsqueeze(0)

    with torch.no_grad():
        output = model(input_tensor)
        _, predicted = torch.max(output, 1)

    predicted_class = class_names[predicted.item()]

    # --- 1차 시도 ---
    nutrition_info = get_nutrition_info(predicted_class)

    # --- 2차 시도: '_' 분리 시도 로직 (유지) ---
    if not nutrition_info and '_' in predicted_class:
        search_words = predicted_class.split('_')
        last_word = search_words[-1]
        nutrition_info = get_nutrition_info(last_word)

    # --- 최종 결과 구성 및 반환 ---

    result_data = {
        'food_name': predicted_class.replace('_', ' ').title(), # 보기 좋게 형식 변경
        'nutrition_details': {},
        'success': False,
    }

    if nutrition_info:
        result_data['success'] = True

        # Flutter에서 사용하기 쉬운 통일된 키로 변경 및 숫자만 추출
        ORDER_MAPPING = {
            'Energy': 'calories',
            'Protein': 'protein',
            'Total lipid (fat)': 'fat',
            'Carbohydrate, by difference': 'carbs',
        }

        final_nutrition = {}
        for original_key, flutter_key in ORDER_MAPPING.items():
            value_str = nutrition_info.get(original_key, 'N/A')

            # 숫자와 단위 분리 (예: '100.0 kcal' -> 100.0)
            try:
                # 첫 번째 단어만 숫자(value)로 추출
                value = float(value_str.split(' ')[0])
            except (ValueError, AttributeError):
                value = 0.0 # 파싱 실패 시 0으로 처리

            final_nutrition[flutter_key] = value

        # (임시 가정) 섭취량은 임시로 100g으로 가정하거나 서버에서 계산해야 함
        result_data['serving_size'] = 100.0

        # Flutter에서 파싱하기 쉽도록 영양소를 최상위 레벨에 통합
        result_data.update(final_nutrition)

    # 이 딕셔너리가 Express 서버로 돌아가 JSON 응답으로 변환됩니다.
    return result_data

# --- 테스트 용 코드 (실제 서버에서는 Express가 호출하므로 제거해야 함) ---
# print(json.dumps(predict_image("img/sandwich.jpg"), indent=4))