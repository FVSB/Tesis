# /home/fvsb/projects/Tesis/mi_modulo/setup.py

from setuptools import setup, find_packages

setup(
    name="mi_modulo",
    version="0.1",
    packages=find_packages(),
    install_requires=[
        # Aquí puedes listar las dependencias necesarias, por ejemplo:
        "numpy",
    ],
    author="Tu Nombre",
    author_email="tuemail@example.com",
    description="Un ejemplo de módulo de Python",
)
