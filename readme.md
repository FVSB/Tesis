
# Generador de Problemas Prueba - Tesis

Sistema para generar problemas de prueba mediante una API en Julia y cliente en Streamlit

## 📋 Requisitos Previos

- **Python 3.6+** instalado y agregado al PATH
- **Julia 1.6+** instalado y agregado al PATH
- **Streamlit**: `pip install streamlit`
- **Git** (para clonar el repositorio)
- **Paquete ArgParse.jl** (se instalará automáticamente)

## 🚀 Configuración Inicial

1. **Clonar el repositorio**
```bash
git clone [URL_DEL_REPOSITORIO]
cd generador-problemas-tesis
```

2. **Configurar entorno virtual de Python**
```bash
python -m venv venv
```

3. **Activar entorno virtual**  
   _Windows:_
```bash
.\venv\Scripts\activate
```
   _Linux/Mac:_
```bash
source venv/bin/activate
```

4. **Instalar dependencias de Python**
```bash
pip install -r requirements.txt
```

## ⚙️ Instalar Dependencias de Julia
```bash
julia install_dependencies.jl
```

## 🏃 Ejecutar la Aplicación

### Servidor API (Julia)
```bash
cd def_problem

# Modo básico (localhost:8080)
julia api.jl

# Modo personalizado (IP y puerto específicos)
julia api.jl --ip 0.0.0.0 --port 9000

# Parámetros disponibles:
#   -i/--ip: Dirección IP (default: 127.0.0.1)
#   -p/--port: Puerto (default: 8080)
#   --help: Muestra ayuda detallada
```

### Cliente Streamlit (Python)
```bash
cd client
streamlit run index.py
```

### ▶️ Método Alternativo para Windows
```bash
setup_and_run.bat
```

## 🌐 Acceder a la Aplicación
- **API**: 
  - Local: `http://127.0.0.1:8080/generate`
  - Red: `http://[IP-DEL-SERVIDOR]:[PUERTO]/generate`
  
- **Cliente Streamlit**: 
  - Se abrirá automáticamente en `http://localhost:8501`

## 🚨 Solución de Problemas

### Problemas Comunes
1. **Dependencias faltantes**:
   ```bash
   # Reinstalar dependencias Python
   pip install -r requirements.txt
   
   # Reinstalar dependencias Julia
   julia install_dependencies.jl
   ```

2. **Puertos en uso**:
   ```bash
   # Windows:
   netstat -ano | findstr :<PUERTO>
   
   # Linux/Mac:
   lsof -i :<PUERTO>
   ```

3. **Acceso en red**:
   - Usar `0.0.0.0` como IP en el servidor
   - Verificar configuración del firewall
   - Usar puertos entre 1024-65535

4. **Errores de rutas**:
   - Ejecutar comandos desde la raíz del proyecto
   - Verificar estructura de carpetas

## 📂 Estructura del Proyecto
```
.
├── venv/               # Entorno virtual Python
├── def_problem/
│   ├── api.jl         # Servidor API (configurable)
│   └── ...            # Otros archivos Julia
├── client/
│   ├── index.py       # Cliente Streamlit
│   └── ...            # Recursos del cliente
├── requirements.txt   # Dependencias Python
├── install_dependencies.jl  # Dependencias Julia
└── setup_and_run.bat  # Script de ejecución para Windows
```

## 📄 Licencia
[Incluir licencia MIT, Apache, o la que corresponda]

---

**Notas importantes**:
- Para desarrollo local mantenga los valores por defecto
- En entornos de producción usar puertos seguros y firewall adecuado
- El endpoint principal de la API es `/generate` (POST)
