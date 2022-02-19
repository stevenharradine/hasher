# Run the program
results1=`bash hasher.sh --help > tests/workspace/results1.log`
results2=`bash hasher.sh --help --enable-advanced-display=false > tests/workspace/results2.log`

#cat tests/results1.log
#echo "----"
#cat tests/results2.log

# Evaluate the test case
if [ "" == *"in progress"* ]; then
	echo "Pass"
else
	echo "Fail"
fi
