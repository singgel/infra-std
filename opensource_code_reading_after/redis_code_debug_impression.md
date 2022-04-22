<!--
 * @Author: your name
 * @Date: 2022-04-22 17:39:32
 * @LastEditTime: 2022-04-22 17:42:19
 * @LastEditors: Please set LastEditors
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /infra-std/opensource_code_reading_after/redis_code_debug_impression.md
-->
## 1.下载源码  

## 2.编译源码  
执行编译的命令，生成对应的目标文件，这里 -O0 是让编译器不进行优化处理  
```make CFLAGS="-g -O0"```  
用 vscode 打开 redis 源码目录，接着点击 运行-->添加配置，选择 C++(GDB/LLDB) 会自动生成 .vscode 文件与 launch.json 文件  

## 3.调试源码  
把生成出来 launch.json 修改成如下：
```{
    // 使用 IntelliSense 了解相关属性。 
    // 悬停以查看现有属性的描述。
    // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "debug redis",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/src/redis-server",
            "args": ["redis.conf"],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb"
        }
    ]
}```