@rem ユーザー名とパスワードが正しいか確認する
@echo off
setlocal enabledelayedexpansion

@rem ユーザー名とパスワードが正しいか確認する
set "username=username"
set "password=p@ssword"

set response_file=%TEMP%\response.txt
set "main_page=https://www.example.com"

curl -u "%username%:%password%" -o nul -s -w "%%{http_code}" "%main_page%" > response_file
set /p status=<response_file
@REM del response_file

if not "%status%"=="200" (
    echo ユーザー名とパスワードとパスワードを使った認証ができませんでした。
    exit /b 1
)

@rem アクセスが必要なブログのアドレスのリスト
set "blogs="
set blogs=%blogs% "https://www.example.com"
set blogs=%blogs% "https://www.google.com"

for %%s in (%blogs%) do (
    echo ^>^>^>^> Accessing %%s
    curl -u "%username%:%password%" -s -I -o nul -w "%%{http_code}\n" %%s > response_file

    set /p status=<response_file
    @rem del response_file 処理速度向上のため、一時ファイルはbatの末尾で削除する

    if not "%status%"=="200" (
        echo アクセスに失敗しました。アドレスを確認してください。
    )
)

curl -u "%username%:%password%" -s -I -o nul -w "%%{http_code}\n" %%s > response_file

findstr /C:"今日のブログ閲覧ノルマを達成しました" response_file >nul
if %errorlevel% equ 0 (
    echo ブログの閲覧ノルマを達成しました。
) else (
    echo ブログの閲覧ノルマ達成を確認できませんでした。
    echo リストに必要なブログが含まれているかを確認してください。
)

del response_file

endlocal
pause
