coverage3 run --source='.' -m behave --no-color

REPORT_DIR=${CYBER_DOJO_SANDBOX}/report
mkdir -p ${REPORT_DIR}

# https://coverage.readthedocs.io/en/v4.5.x/index.html

coverage3 \
  report \
    --show-missing \
      > ${REPORT_DIR}/coverage.txt

# http://pycodestyle.pycqa.org/en/latest/intro.html#configuration

pycodestyle \
  ${CYBER_DOJO_SANDBOX} \
    --show-source `# show source code for each error` \
    --show-pep8   `# show relevent text from pep8` \
    --ignore E302,E305,W293 \
    --max-line-length=80 \
      > ${REPORT_DIR}/style.txt

# E302 expected 2 blank lines, found 0
# E305 expected 2 blank lines after end of function or class
# W293 blank line contains whitespace
