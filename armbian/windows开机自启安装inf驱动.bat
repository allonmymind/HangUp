@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"
:: 在管理员权限下运行命令


pnputil -i -a D:\athw10x.inf_amd64_ade1b55fc54b1b4a\athw10x.inf



