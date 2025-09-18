# Node.js 런타임 버전을 명시합니다. Alpine 버전은 이미지 크기를 줄여줍니다.
FROM node:20-alpine

# 컨테이너 내부에 앱 디렉토리를 생성합니다.
WORKDIR /usr/src/app

# 앱 종속성을 설치하기 위해 package.json 및 package-lock.json을 복사합니다.
# Docker의 레이어 캐싱을 활용하여 불필요한 재설치를 방지합니다.
COPY package*.json ./

# 앱 종속성을 설치합니다.
# 프로덕션 환경에서는 'npm ci --only=production'을 사용하는 것이 더 안정적이고 빠릅니다.
RUN npm install

# 앱 소스 코드를 컨테이너 내부로 복사합니다.
COPY . .

# 앱이 3000번 포트를 사용한다고 가정하고 외부에 노출시킵니다.
EXPOSE 3000

# 컨테이너가 시작될 때 실행할 명령어를 정의합니다.
CMD [ "node", "app.js" ]