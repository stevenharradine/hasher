echo -n "Help functionality . "

# Set up workspace
echo "file1" > tests/workspace/file1.avi

# Run the program
results1=`bash hasher.sh --help`
results2=`bash hasher.sh -h`
results3=`bash hasher.sh -?`

# Evaluate the test case
keyText="Will enable this help window"
if [[ $results1 == *$keyText* ]] &&
   [[ $results2 == *$keyText* ]] &&
   [[ $results3 == *$keyText* ]]; then
	echo "Pass"
	((++number_of_tests_passed))
else
	echo "Fail"
	((++number_of_tests_failed))
fi
