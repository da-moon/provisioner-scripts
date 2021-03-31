(Invoke-WebRequest -Uri https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py -UseBasicParsing).Content | python -
python -m pip install cleo tomlkit poetry.core cachecontrol cachy html5lib pkginfo virtualenv lockfile
