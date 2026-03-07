from setuptools import setup

setup(
    name="python-devops-app",
    version="1.0",
    py_modules=["app"],
    install_requires=[
        "Flask",
        "gunicorn"
    ],
)
