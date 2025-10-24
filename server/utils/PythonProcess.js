import { spawn } from 'child_process';

export class PythonProcess {

  static executePython = (fileName, args) => {
    return new Promise((resolve, reject) => {
      // spawn 함수에 전달할 인자 배열
      const spawnArgs = [fileName, ...args];
      const pythonProcess = spawn('python3', spawnArgs);

      let output = '';
      let error = '';


      // 자식 프로세스의 stdout에서 데이터를 수집
      pythonProcess.stdout.on('data', (data) => {
        output += data.toString();
      });

      // 자식 프로세스의 stderr에서 에러를 수집
      pythonProcess.stderr.on('data', (data) => {
        error += data.toString();
      });

      // 자식 프로세스가 종료되면 Promise를 resolve 또는 reject
      pythonProcess.on('close', (code) => {
        ƒ
        if (code !== 0) {
          // 에러가 발생하면 Promise를 reject
          reject(new Error(`Python process exited with code ${code}. Error: ${error}`));
        } else {
          // 성공적으로 종료되면 결과를 resolve
          resolve(output.trim());
        }
      });
    });
  };


}