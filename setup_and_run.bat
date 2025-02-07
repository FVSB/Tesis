@echo off
REM Script para configurar y ejecutar el proyecto

echo Creando entorno virtual de Python...
python -m venv venv

echo Activando entorno virtual e instalando dependencias...
call venv\Scripts\activate.bat
pip install -r requirements.txt

echo Instalando dependencias de Julia...
julia install_dependencies.jl

echo Iniciando la API...
cd def_problem
start "" julia api.jl
cd ..

echo Iniciando el cliente Streamlit...
cd client
start "" streamlit run index.py
cd ..

echo ¡Configuracion completa! La API y el cliente se estan ejecutando.
pause