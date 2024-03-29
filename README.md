# hasher
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Tests](https://github.com/stevenharradine/hasher/actions/workflows/tests.yml/badge.svg)](https://github.com/stevenharradine/hasher/actions/workflows/tests.yml)

Hasher will create a new hash file along side your existing files you want to preserve or archive.  If you have a file called important-document.txt inside a folder called "My Documents".  If you run hasher `./hasher --mode=create --directory="~/My Documents"` it will create and save a hash of your files in that folder alongside the files themself.  So in this example it would create ~/My Documents/important-document.txt.md5.  This new hash can now be used to verify the integrity of this file.  Hasher supports a wide range of hashes and 1, many, and all supported hashes can be used in combinantions with each other.

## install hasher
curl https://raw.githubusercontent.com/stevenharradine/bashInstaller/master/installer.sh | bash -s program=hasher

## using hasher
```
./hasher.sh [options]

  options:
    --mode=(create, check, help) what mode to run hasher in
    --directory=the directory you want hasher to run against
    --enable-md5={true|false}
    --enable-sha1={true|false}
    --enable-sha256={true|false}
    --find-missing={true|false}, do not scan the files but just look for missing hashes
    --enable-report={true|false}, write the final report to the --report-location
    --report-location=the location to write the final report when --enable-report flag is set to true
    --update, update this program with the lastest version from git
    --help, -h, -? Will enable this help window

usage: ./hasher.sh --mode=create --directory=/home/pi/videos --enable-md5=false
```
## Tests
### To run the test suite
./run-tests.sh
### new tests
add new tests to the tests folder, use test-template.sh as an example
