echo -n "Create proper md5 hash . "

# Set up workspace
echo "file1" > tests/workspace/file1.avi

# Run the program
results=`bash hasher.sh --mode=create --directory=tests/workspace`

# Evaluate the test case
if [ "`cat tests/workspace/file1.avi.md5`" == "5149d403009a139c7e085405ef762e1a" ]; then
	echo "Pass"
	((++number_of_tests_passed))
else
	echo "Fail"
	((++number_of_tests_failed))
fi
