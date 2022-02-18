#!/bin/bash
# Copyright Steven Harradine 2022
number_of_tests=0
number_of_tests_passed=0
number_of_tests_failed=0
workspace_directory=tests/workspace

while read script ; do
	mkdir -p "$workspace_directory"

	source $script
	((++number_of_tests))

	rm -r "$workspace_directory"
done <<< "$(eval "find tests/ -type f ! -name \"test-template.sh\" -name \"*.sh\"" | sort -t '\0' -n)"

echo ""
echo "Resuts"
echo "******"
echo ""
echo "    Number of Tests: $number_of_tests"
echo "             Passed: $number_of_tests_passed"
echo "             Failed: $number_of_tests_failed"
echo ""
echo -n "         Test suite: "
if [ $number_of_tests_failed -eq 0 ]; then
	echo "Passed"
else
	echo "Failed"
	exit -1
fi
