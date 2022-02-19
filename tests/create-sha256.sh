# Set up workspace
echo "file1" > tests/workspace/file1.avi

# Run the program
results=`bash hasher.sh --mode=create --directory=tests/workspace`

# Evaluate the test case
if [ "`cat tests/workspace/file1.avi.sha256`" == "ecdc5536f73bdae8816f0ea40726ef5e9b810d914493075903bb90623d97b1d8" ]; then
	echo "Pass"
else
	echo "Fail"
fi
