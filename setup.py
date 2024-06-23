from setuptools import setup, find_packages

with open("requirements.txt") as f:
    required = f.read().splitlines()

setup(
    name="template_populator",
    author="Dr. Malte Harland",
    packages=find_packages(),
    install_requires=required,
    package_data={
        "": ["**/*.json"],
    },
)
