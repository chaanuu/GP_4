# GP_4 서버 API 문서

이 문서는 GP_4 프로젝트의 서버 API에 대한 명세를 제공합니다. 각 엔드포인트에 대한 설명, 요청 방법, 요청/응답 데이터 형식을 포함하고 있습니다.

## 기본 정보

- **Base URL:** `http://localhost:<port>`
- **Content-Type:** `application/json`

---

## 엔드포인트

### 1. 사용자 관리 (`/user`)

#### 1.1 GET `/user`
- **설명**: 모든 사용자 정보 가져오기
- **응답**
  - **200 OK**
    ```json
    [
      { "id": 1, "name": "John Doe", "email": "john@example.com" },
      { "id": 2, "name": "Jane Doe", "email": "jane@example.com" }
    ]
    ```

---

#### 1.2 GET `/user/:id`
- **설명**: 특정 사용자 정보 가져오기
- **매개변수**
  - `:id` (URL Path) - 사용자 ID
- **응답**
  - **200 OK**
    ```json
    { "id": 1, "name": "John Doe", "email": "john@example.com" }
    ```
  - **404 Not Found**
    ```json
    { "error": "User not found" }
    ```

---

#### 1.3 POST `/user`
- **설명**: 새 사용자 생성
- **요청**
  - **Body**
    ```json
    { "name": "John Doe", "email": "john@example.com" }
    ```
- **응답**
  - **201 Created**
    ```json
    { "id": 3, "name": "John Doe", "email": "john@example.com" }
    ```

---

#### 1.4 PUT `/user/:id`
- **설명**: 사용자 정보 업데이트
- **매개변수**
  - `:id` (URL Path) - 사용자 ID
- **요청**
  - **Body**
    ```json
    { "name": "John Doe Updated" }
    ```
- **응답**
  - **200 OK**
    ```json
    { "id": 1, "name": "John Doe Updated", "email": "john@example.com" }
    ```

---

#### 1.5 DELETE `/user/:id`
- **설명**: 사용자 삭제
- **매개변수**
  - `:id` (URL Path) - 사용자 ID
- **응답**
  - **204 No Content**

---

### 2. 운동 관리 (`/exercise`)

#### 2.1 GET `/exercise`
- **설명**: 모든 운동 정보 가져오기
- **응답**
  - **200 OK**
    ```json
    [
      { "id": 1, "name": "Push Up", "mets": 3.5, "mainMuscle": "Chest" },
      { "id": 2, "name": "Squat", "mets": 4.0, "mainMuscle": "Legs" }
    ]
    ```

---

#### 2.2 GET `/exercise/:id`
- **설명**: 특정 운동 정보 가져오기
- **매개변수**
  - `:id` (URL Path) - 운동 ID
- **응답**
  - **200 OK**
    ```json
    { "id": 1, "name": "Push Up", "mets": 3.5, "mainMuscle": "Chest" }
    ```
  - **404 Not Found**
    ```json
    { "error": "Exercise not found" }
    ```

---

#### 2.3 POST `/exercise`
- **설명**: 새 운동 생성
- **요청**
  - **Body**
    ```json
    { "name": "Push Up", "mets": 3.5, "mainMuscle": "Chest" }
    ```
- **응답**
  - **201 Created**
    ```json
    { "id": 3, "name": "Push Up", "mets": 3.5, "mainMuscle": "Chest" }
    ```

---

#### 2.4 PUT `/exercise/:id`
- **설명**: 운동 정보 업데이트
- **매개변수**
  - `:id` (URL Path) - 운동 ID
- **요청**
  - **Body**
    ```json
    { "name": "Push Up Updated", "mets": 3.6 }
    ```
- **응답**
  - **200 OK**
    ```json
    { "id": 1, "name": "Push Up Updated", "mets": 3.6, "mainMuscle": "Chest" }
    ```

---

#### 2.5 DELETE `/exercise/:id`
- **설명**: 운동 삭제
- **매개변수**
  - `:id` (URL Path) - 운동 ID
- **응답**
  - **204 No Content**

---

### 3. 음식 관리 (`/food`)

#### 3.1 GET `/food`
- **설명**: 모든 음식 정보 가져오기
- **응답**
  - **200 OK**
    ```json
    [
      { "id": 1, "name": "Apple", "calories": 95 },
      { "id": 2, "name": "Banana", "calories": 105 }
    ]
    ```

---

#### 3.2 POST `/food`
- **설명**: 새 음식 데이터 생성
- **요청**
  - **Body**
    ```json
    { "name": "Apple", "calories": 95 }
    ```
- **응답**
  - **201 Created**
    ```json
    { "id": 3, "name": "Apple", "calories": 95 }
    ```

---

### 4. OAuth 로그인 (`/oauth`)

#### 4.1 POST `/oauth/googleCallback`
- **설명**: Google 로그인 콜백 URI 
- **요청**
  - **Body**
    ```json
    { "code": "google-id-secret-code" }
    ```
- **응답**
  - **200 OK**
    ```json
    { "message": "Login successful", "jwtTokens": { "accessToken": "JWT accessToken", "refreshToken": "JWT refreshToken" } }
    ```

---

#### 4.2 POST `/oauth/apple`
- **설명**: Apple 로그인 처리
- **요청**
  - **Body**
    ```json
    { "idToken": "apple-id-token" }
    ```
- **응답**
  - **200 OK**
    ```json
    { "message": "Login successful", "user": { "id": 1, "name": "John Doe", "email": "john@example.com" } }
    ```

---

## 참고
- 엔드포인트 및 기능은 현재 코드 기반으로 작성되었습니다. 필요에 따라 업데이트가 요구됩니다.
