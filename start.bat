@echo off
setlocal enabledelayedexpansion
title Quant Backtest System

echo.
echo ========================================
echo       Quant Backtest System
echo ========================================
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found! Please install Python 3.8+
    echo Download: https://www.python.org/downloads/
    pause
    exit /b 1
)

node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js not found! Please install Node.js 16+
    echo Download: https://nodejs.org/
    pause
    exit /b 1
)

echo Environment check passed.
echo.

:menu
echo ========================================
echo   Select an option:
echo ========================================
echo.
echo   1. Install dependencies
echo   2. Download stock data
echo   3. Start backend server
echo   4. Start frontend server
echo   5. Start all servers
echo   0. Exit
echo.
set choice=
set /p choice="Enter option (0-5): "

if "!choice!"=="1" goto install
if "!choice!"=="2" goto download
if "!choice!"=="3" goto backend
if "!choice!"=="4" goto frontend
if "!choice!"=="5" goto all
if "!choice!"=="0" goto end

echo.
echo Invalid option, please enter 0-5
echo.
goto menu

:install
echo.
echo ========================================
echo   Installing dependencies...
echo ========================================
echo.

echo [1/2] Installing backend dependencies...
cd /d "%~dp0backend"
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 (
    echo [ERROR] Backend install failed
    cd /d "%~dp0"
    pause
    goto menu
)
cd /d "%~dp0"
echo Backend dependencies installed.

echo.
echo [2/2] Installing frontend dependencies...
cd /d "%~dp0frontend"
call npm install
if errorlevel 1 (
    echo [ERROR] Frontend install failed
    cd /d "%~dp0"
    pause
    goto menu
)
cd /d "%~dp0"
echo Frontend dependencies installed.

echo.
echo ========================================
echo   Dependencies installed successfully!
echo ========================================
echo.
pause
goto menu

:download
echo.
echo ========================================
echo   Download Stock Data
echo ========================================
echo.
cd /d "%~dp0backend"
python data_fetcher.py
cd /d "%~dp0"
pause
goto menu

:backend
echo.
echo ========================================
echo   Starting backend server (port 8080)
echo ========================================
echo.
cd /d "%~dp0backend"
start "Quant-Backend" cmd /k python main.py
cd /d "%~dp0"
echo Backend started!
echo API docs: http://localhost:8080/docs
echo.
pause
goto menu

:frontend
echo.
echo ========================================
echo   Starting frontend server (port 5173)
echo ========================================
echo.
cd /d "%~dp0frontend"
if not exist "node_modules" (
    echo Installing frontend dependencies...
    call npm install
)
start "Quant-Frontend" cmd /k npm run dev
cd /d "%~dp0"
echo Frontend started!
echo URL: http://localhost:5173
echo.
pause
goto menu

:all
echo.
echo ========================================
echo   Starting all servers...
echo ========================================
echo.

echo Starting backend...
cd /d "%~dp0backend"
start "Quant-Backend" cmd /k python main.py
cd /d "%~dp0"

echo Starting frontend...
cd /d "%~dp0frontend"
if not exist "node_modules" (
    echo Installing frontend dependencies...
    call npm install
)
start "Quant-Frontend" cmd /k npm run dev
cd /d "%~dp0"

echo.
echo ========================================
echo   All servers started!
echo ========================================
echo   Frontend: http://localhost:5173
echo   Backend:  http://localhost:8080/docs
echo ========================================
echo.
pause
goto menu

:end
echo.
echo Goodbye!
timeout /t 2 >nul
exit /b 0
