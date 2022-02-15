echo -n "Disable sha256 . "

# Set up workspace
echo "file1" > tests/workspace/file1.avi

# Run the program
results=`bash hasher.sh --mode=create --directory=tests/workspace --enable-sha256=false`

# Evaluate the test case
if [ ! -f tests/workspace/file1.avi.sha256 ]; then
	echo "Pass"
	((++number_of_tests_passed))
else
	echo "Fail"
	((++number_of_tests_failed))
fi
