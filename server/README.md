"# Server Module" 


 # DB 가이드

-- 사용자 정보를 저장하는 테이블
CREATE TABLE `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `name` VARCHAR(255),
  `password_hash` VARCHAR(255),
  `provider` VARCHAR(50) NOT NULL DEFAULT 'local',
  `provider_id` VARCHAR(255),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_provider` (`provider`, `provider_id`)
);

-- 운동 정보를 저장하는 테이블 (기본 운동 + 사용자 정의 운동)
CREATE TABLE `exercises` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `userId` INT,
  `name` VARCHAR(255) NOT NULL,
  `mets` FLOAT,
  `code` VARCHAR(255),
  `mainMuscle` VARCHAR(100),
  `subMuscle` VARCHAR(100),
  `dateExecuted` DATE,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- 사용자의 운동 기록을 저장하는 테이블
CREATE TABLE `exercise_logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `userId` INT NOT NULL,
  `exerciseId` INT NOT NULL,
  `reps` INT,
  `sets` INT,
  `dateExecuted` DATE NOT NULL,
  `durationMinutes` INT,
  `caloriesBurned` FLOAT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`exerciseId`) REFERENCES `exercises`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_date` (`userId`, `dateExecuted`)
);

-- 음식 정보를 저장하는 테이블 (기본 음식 + 사용자 정의 음식)
CREATE TABLE `foods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `userId` INT,
  `name` VARCHAR(255) NOT NULL,
  `kcal` FLOAT,
  `carb` FLOAT,
  `protein` FLOAT,
  `fat` FLOAT,
  `imgUrl` VARCHAR(2048),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- 사용자의 식사 기록을 저장하는 테이블
CREATE TABLE `meal_logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `userId` INT NOT NULL,
  `foodId` INT NOT NULL,
  `quantity` FLOAT,
  `timeConsumed` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`foodId`) REFERENCES `foods`(`id`) ON DELETE CASCADE
);

-- 사용자의 일일 활동량(걸음 수, 소모 칼로리)을 저장하는 테이블
CREATE TABLE `user_activity_logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `walk_steps` INT,
  `kcal_burned` FLOAT,
  `date` DATE NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `user_date_unique` (`user_id`, `date`)
);