@echo off
echo Setting up Autopredator Car Research Web...

REM Check if PHP is installed
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo PHP is not installed or not in PATH. Please install PHP 8.1+ and add it to your PATH.
    echo Download from: https://windows.php.net/download
    pause
    exit /b 1
)

REM Check if Composer is installed
composer --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Composer is not installed. Installing Composer...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://getcomposer.org/installer' -OutFile 'composer-setup.php'}"
    php composer-setup.php --install-dir=. --filename=composer
    del composer-setup.php
)

REM Install PHP dependencies
echo Installing PHP dependencies...
composer install

REM Set environment variables
set APP_ENV=local
set USE_JSON=true

REM Start the development server
echo Starting development server on http://localhost:8000
php -S localhost:8000

pause
