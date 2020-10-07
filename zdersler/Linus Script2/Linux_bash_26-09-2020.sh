#!/bin/bash
number=5
python3 -c "print($number)"
***************
#!/bin/bash
num1=5
num2=4
python3 -c "print( $num1 + $num2 )"
******************
#!/bin/bash
n1=5
n2=4
code=$(cat <<END
print($n1)
print($n2)
print($n1 + $n2)
END
)
python3 -c “$code“
******************
python3 -c “./mycode.py”
**************
#!/bin/bash
END_VALUE=10
PYTHON_CODE=$(cat << _END_
# Python code starts here...
import math
for i in range($END_VALUE):
   print(i, math.sqrt(i))
# Python code ends here.
_END_
)
res="$(python3 -c "$PYTHON_CODE")"
echo "$res"