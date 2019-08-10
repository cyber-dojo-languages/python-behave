coverage3 run --source='.' -m behave --no-color
echo; echo
coverage3 report -m
echo; echo
pycodestyle /sandbox
