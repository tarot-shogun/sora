@rem ���[�U�[���ƃp�X���[�h�����������m�F����
@echo off
setlocal enabledelayedexpansion

@rem ���[�U�[���ƃp�X���[�h�����������m�F����
set "username=username"
set "password=p@ssword"

set response_file=%TEMP%\response.txt
set "main_page=https://www.example.com"

curl -u "%username%:%password%" -o nul -s -w "%%{http_code}" "%main_page%" > response_file
set /p status=<response_file
@REM del response_file

if not "%status%"=="200" (
    echo ���[�U�[���ƃp�X���[�h�ƃp�X���[�h���g�����F�؂��ł��܂���ł����B
    exit /b 1
)

@rem �A�N�Z�X���K�v�ȃu���O�̃A�h���X�̃��X�g
set "blogs="
set blogs=%blogs% "https://www.example.com"
set blogs=%blogs% "https://www.google.com"

for %%s in (%blogs%) do (
    echo ^>^>^>^> Accessing %%s
    curl -u "%username%:%password%" -s -I -o nul -w "%%{http_code}\n" %%s > response_file

    set /p status=<response_file
    @rem del response_file �������x����̂��߁A�ꎞ�t�@�C����bat�̖����ō폜����

    if not "%status%"=="200" (
        echo �A�N�Z�X�Ɏ��s���܂����B�A�h���X���m�F���Ă��������B
    )
)

curl -u "%username%:%password%" -s -I -o nul -w "%%{http_code}\n" %%s > response_file

findstr /C:"�����̃u���O�{���m���}��B�����܂���" response_file >nul
if %errorlevel% equ 0 (
    echo �u���O�̉{���m���}��B�����܂����B
) else (
    echo �u���O�̉{���m���}�B�����m�F�ł��܂���ł����B
    echo ���X�g�ɕK�v�ȃu���O���܂܂�Ă��邩���m�F���Ă��������B
)

del response_file

endlocal
pause
