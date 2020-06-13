#!/usr/bin/env bash
set -euo pipefail

setup_python_emacs() {
    sudo dnf install -y python3 \
        python3-setuptools \
        conda \
        poetry \
        python3-Cython \
        python3-ipython \
        python3-pytest \
        python3-nose \
        pipenv \
        python3-isort \
        python3-pyflakes \
        black \
        pylint \
        python3-flake8 \
        python3-jupyter-core
    pip install -U setuptools \
        cython \
        ipython \
        pytest \
        nose \
        isort \
        pyflakes \
        pylint \
        flake8 \
        jupyter
}
