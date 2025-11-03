import { spawn } from 'child_process';
import path from 'path';
import { FileNotFoundError, PythonProcessError } from './errors.js';

export class PythonProcess {

  static executePython = (fileName, args) => {
    return new Promise((resolve, reject) => {
      // spawn 함수에 전달할 인자 배열
      const absoluteFilePath = path.join(__dirname, 'script_python', fileName);
      const spawnArgs = [absoluteFilePath, ...args];
      const pythonProcess = spawn('python', spawnArgs);

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
        if (code === 0) {
          // 성공적으로 종료되면 결과를 resolve
          resolve(output.trim());
        }
        else if (code === 1) {
          // 일반 실행 오류
          reject(new PythonProcessError(`Python script ${fileName} execution error: ${error.trim()}`));
        } else if (code === 2) {
          // 인자로 받는 이미지 파일이 없을 때
          reject(new FileNotFoundError(`Source Argument file ${args[0]} not found.`));
        }
        else if (code === 127) {
          // Python 인터프리터를 찾을 수 없을 때
          reject(new PythonProcessError(`Python interpreter not found. Make sure Python is installed and accessible.`));
        }

      });
    });
  };


}