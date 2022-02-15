echo -n "Create proper sha1 hash . "

# Set up workspace
echo "file1" > tests/workspace/file1.avi

# Run the program
results=`bash hasher.sh --mode=create --directory=tests/workspace`

# Evaluate the test case
if [ "`cat tests/workspace/file1.avi.sha1`" == "38be7d1b981f2fb6a4a0a052453f887373dc1fe8" ]; then
	echo "Pass"
	((++number_of_tests_passed))
else
	echo "Fail"
	((++number_of_tests_failed))
fi
