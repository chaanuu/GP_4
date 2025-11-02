/** @type {import('ts-jest').JestConfigWithTsJest} */
export default {
    // Jest가 테스트를 실행할 환경을 설정합니다.
    // 'node'는 Node.js 환경에서 서버 사이드 코드를 테스트할 때 사용됩니다.
    // 프론트엔드 코드를 테스트하는 경우 'jsdom'을 사용할 수 있습니다.
    testEnvironment: 'node',

    // 테스트 파일을 찾기 위한 패턴을 지정합니다.
    // 기본적으로 __tests__ 폴더 내의 파일이나 .spec.js, .test.js로 끝나는 파일을 찾습니다.
    testMatch: [
        '**/__tests__/**/*.?(m)[jt]s?(x)',
        '**/?(*.)+(spec|test).?(m)[jt]s?(x)',
    ],

    // TypeScript 파일을 테스트하기 위해 ts-jest를 사용하도록 설정합니다.
    // preset을 사용하면 기본적인 ts-jest 설정이 자동으로 적용됩니다.
    preset: 'ts-jest',

    // 각 테스트가 실행되기 전에 모의(mock) 호출, 인스턴스, 컨텍스트를 자동으로 지웁니다.
    // 테스트 간의 독립성을 보장하는 데 도움이 됩니다.
    clearMocks: true,

    // 코드 커버리지 정보를 수집하도록 설정합니다.
    collectCoverage: true,

    // 코드 커버리지 리포트를 생성할 디렉토리를 지정합니다.
    coverageDirectory: 'coverage',

    // 코드 커버리지를 계산할 때 사용할 프로바이더를 설정합니다.
    // 'v8'은 Node.js에 내장된 V8 엔진의 커버리지 기능을 사용해 더 빠를 수 있습니다.
    coverageProvider: 'v8',

    // 모듈을 찾을 때 사용할 파일 확장자 목록입니다.
    moduleFileExtensions: ['js', 'mjs', 'cjs', 'jsx', 'ts', 'tsx', 'json', 'node'],

    // 특정 모듈이나 파일을 변환에서 제외할 패턴을 지정합니다.
    // transformIgnorePatterns: [
    //     // node_modules의 모든 파일을 무시하지만, apple-signin-auth는 제외하고 변환하도록 허용합니다.
    //     '/node_modules/(?!(apple-signin-auth)/)',
    // ],

    moduleNameMapper: {
        // 'apple-signin-auth' 모듈을 CommonJS 방식으로 처리하도록 매핑합니다.
        // 실제 경로에 따라 'node_modules/apple-signin-auth/dist/cjs/index.js'와 같은 CJS 파일 경로를 사용해야 할 수도 있습니다.
        '^apple-signin-auth$': '<rootDir>/node_modules/apple-signin-auth',
    },
};