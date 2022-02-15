echo -n "Find missing . "

# Set up workspace
echo "file1" > tests/workspace/file1.avi

# Run the program
results=`bash hasher.sh --mode=check --directory=tests/workspace --find-missing`

# Evaluate the test case
if [[ $results == *"md5 Missing(?): 1"* ]] &&
   [[ $results == *"sha1 Missing(?): 1"* ]] &&
   [[ $results == *"sha256 Missing(?): 1"* ]]; then
	echo "Pass"
	((++number_of_tests_passed))
else
	echo "Fail"
	((++number_of_tests_failed))
fi
