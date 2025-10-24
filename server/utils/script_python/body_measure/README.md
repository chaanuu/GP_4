# Body Measurement Module (PARE 기반)

이 모듈은 [PARE (Part Attention Regressor for 3D Human Body Estimation)](https://github.com/mkocabas/PARE)를 기반으로,  
사용자의 체형 변화를 정량적으로 분석하기 위한 **허리/허벅지/팔 둘레 측정 기능**을 제공합니다.  

졸업 프로젝트에서 사용자가 촬영한 전신 사진으로부터 **SMPL 파라미터(β, θ, camera)**를 추출하고,  
이를 바탕으로 특정 신체 부위의 둘레를 자동으로 계산합니다.

---

##  기능
- PARE를 통해 추출된 `.pkl` 결과 파일을 입력으로 사용
- SMPL 모델을 기반으로 다음 부위의 둘레 자동 측정:
  - 허리 둘레
  - 허벅지 둘레
  - 팔 둘레
- 현재는 변화량만 제공하지만 추후 업데이트 예정

---

##  폴더 구조
body_measure/
├── measure_circumference_auto.py   # 신체 둘레 자동 계산 스크립트
├── requirements.txt                # 실행 환경 패키지 목록
├── README.md                       # 설명 문서
│
├── examples/                       # 입력 이미지 (Before / After 등)
│   ├── image1.jpg
│   └── image2.jpg
│
├── output/                         # PARE 실행 결과
│   └── pare_results/               # SMPL 파라미터(.pkl) 저장 폴더
│       ├── image1.pkl
│       └── image2.pkl
---

## 설치 방법
Python 3.8 환경 권장
(예: conda 환경 생성)
conda create -n pare-fresh python=3.8
conda activate pare-fresh

필수 패키지 설치
pip install -r requirements.txt


##실행 방법
PARE 실행
PYTHONPATH=./yolov3 python scripts/demo.py \
  --cfg scripts/data/pare/checkpoints/pare_w_3dpw_config.yaml \
  --ckpt scripts/data/pare/checkpoints/pare_w_3dpw_checkpoint.ckpt \
  --image_folder ./examples \
  --output_folder ./output \
  --mode folder --no_render
실행 후 ./output 폴더에 SMPL 파라미터가 담긴 .pkl 파일이 생성됩니다.

신체 둘레 계산 실행
python measure_circumference.py

출력 예시
=== 부위별 둘레 변화 ===
허리: Before 1.01, After 1.01, 변화 -0.00
허벅지: Before 1.16, After 1.17, 변화 +0.01
팔: Before 0.73, After 0.67, 변화 -0.06

##참고
PARE 및 SMPL 모델의 weight 파일은 깃허브에 포함하지 않았습니다.
이를 포함한 추가로 필요한 것들은 추후 RAEDME.md에 업로드하겠습니다.
본 모듈은 PARE 출력(.pkl)을 기반으로만 동작합니다.

##기여
본 모듈은 졸업 프로젝트의 체형 변화 분석 기능을 담당합니다.
추가적인 피드백 및 수정은 feature/body-measure 브랜치에서 진행 예정입니다.
