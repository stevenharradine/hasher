#!/bin/bash
# Copyright Steven Harradine 2022
number_of_tests=0
number_of_tests_passed=0
number_of_tests_failed=0
workspace_directory=tests/workspace

while read script ; do
	mkdir -p "$workspace_directory"

	result=`source $script`
	title=${script:6:-3}												# remove tests/ and .sh
	title=`echo $title | sed 's/-/ /g'`									# dashes to spaces
	title="$(tr '[:lower:]' '[:upper:]' <<< ${title:0:1})${title:1}"	# upper case first char

	echo "$title . $result"
	
	if [ "$result" == "Pass" ]; then
		((++number_of_tests_passed))
	elif [ "$result" == "Fail" ]; then
		((++number_of_tests_failed))
	fi

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
