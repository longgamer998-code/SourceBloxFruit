@echo off
cd /d "%~dp0"

echo ===============================
echo   ADD LUA FILES TO GIT
echo   (NO STASH WORKFLOW)
echo ===============================

if not exist ".git" (
    echo ERROR: Not a git repository!
    pause
    exit /b
)

echo Checking repo status...
git status --short

echo.
echo Pulling latest changes...
git pull --rebase
if errorlevel 1 (
    echo ERROR: Repo not clean. Commit or restore files first.
    pause
    exit /b
)

dir *.lua >nul 2>&1
if errorlevel 1 (
    echo No Lua files found. Nothing to add.
    pause
    exit /b
)

git add *.lua
git commit -m "Update Lua files"
git push

echo DONE!
pause
