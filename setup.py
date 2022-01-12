#!/usr/bin/env python

"""The setup script."""

from setuptools import setup, find_packages

with open("README.rst") as readme_file:
    readme = readme_file.read()

requirements = [
    "flask==2.0.2",
    "joblib==1.1.0",
    "scikit-learn==1.0.1",
    "pandas==1.3.4",
    "python-dotenv==0.19.2",
]
test_requirements = ["pytest>=3", "pytest-cov"]
development_requirements = ["pre-commit", "bump2version"]
documentation_requirements = ["sphinx", "sphinx-panels"]

setup(
    author="Lennart Damen",
    author_email="lennart.damen@coolblue.nl",
    python_requires="==3.9.7",
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Programming Language :: Python :: 3",
    ],
    description="Workshop on how to deploy models on GCP",
    install_requires=requirements,
    tests_require=test_requirements,
    extras_require={
        "dev": test_requirements + development_requirements,
        "docs": documentation_requirements,
    },
    license="MIT license",
    long_description=readme,
    include_package_data=True,
    keywords="deployment_workshop",
    name="deployment_workshop",
    packages=find_packages(include=["deployment_workshop", "deployment_workshop.*"]),
    url="https://github.com/lennart-damen/deployment_workshop",
    version="0.0.0",
    zip_safe=False,
)
