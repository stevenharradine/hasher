#!/bin/bash
# Copyright Steven Harradine 2023
HASHER_VERSION=0.3.1
mode=help
dir="./"
filetypes_videos=(avi mkv mp4 ts mts m2ts mpg mpeg wmv wv flv webm vob ogv ogg rm asf wtv mov)
filetypes_images=(jpeg jpg gif bmp svg)
filetypes_audio=(mp3 flac wav)
filetypes_documents=(txt doc docx pdf xls odf xlsx)
filetypes=("${filetypes_videos[@]}")
startTime=`date '+%a %d %b %Y %T %Z'`
findArgs=""
enable_md5=true
enable_sha1=true
enable_sha256=true
findMissing=false
fileCounter=0
enable_advanced_display=false
enable_report=false
report_location=report.txt

## only if the session is interactive will we use the advanced displays
tty -s && enable_advanced_display=true

# parse arguments passed into hasher
for arg in "$@"; do
	key=`echo "$arg" | awk -F "=" '{print $1}'`
	value=`echo "$arg" | awk -F "=" '{print $2}'`

	if [[ $key == "--mode" ]]; then
		mode=$value
	elif [[ $key == "--directory" ]]; then
		dir=$value
	elif [[ $key == "--enable-md5" ]]; then
		enable_md5=$value
	elif [[ $key == "--enable-sha1" ]]; then
		enable_sha1=$value
	elif [[ $key == "--enable-sha256" ]]; then
		enable_sha256=$value
	elif [[ $key == "--find-missing" ]]; then
		findMissing=$value
	elif [[ $key == "--enable-advanced-display" ]]; then
		enable_advanced_display=$value
	elif [[ $key == "--enable-report" ]]; then
		enable_report=$value
	elif [[ $key == "--report-location" ]]; then
		report_location=$value
	elif [[ $key == "--update" ]]; then
		mode="update"
	elif [[ $key == "--help" ]] || [[ $key == "-?" ]] || [[ $key == "-h" ]]; then
		mode="help"
	fi
done

# build arguments to 'find' all supported file types
for extention in "${filetypes[@]}"
do
	findArgs="$findArgs -name '*.$extention' -or"
done
findArgs=${findArgs::-4}	# remove the last instance of ' -or' to make the argument valid for the 'find' command

# clear the screen before we start jumping all over the place and drawing
if [ $enable_advanced_display == true ]; then
	tput clear
fi

if [[ $mode == "create" ]]; then
	md5Generated=0
	md5Exists=0
	md5Skipped=0

	sha1Generated=0
	sha1Exists=0
	sha1Skipped=0

	sha256Generated=0
	sha256Exists=0
	sha256Skipped=0

	while read nestedPath ; do
		if [ -f "$nestedPath" ]; then
			filename="${nestedPath%.*}"

			seconds1=$(date +%s)
			seconds2=$(date --date "$startTime" +%s)
			delta=$((seconds1 - seconds2))
			formatedTime=`printf '%dh:%dm:%ds\n' $((delta/3600)) $((delta%3600/60)) $((delta%60))`

			# clear first line
			if [ $enable_advanced_display == true ]; then
				tput cup 0 0
				echo -e "\033[2K"

				# Display report
				tput cup 2 0
				echo "Report (in progress)"
				echo "********************"
				echo "          Directory: $dir"
				echo "               Mode: $mode"
				echo "         Start Time: $startTime"
				echo "           End Time: in progress"
				echo "           Duration: $formatedTime"
				echo "    Number of files: $fileCounter"
				echo ""
				echo "   md5 generated(g): $md5Generated"
				echo "      md5 exists(e): $md5Exists"
				echo "     md5 Skipped(s): $md5Skipped"
				echo ""
				echo "  sha1 generated(g): $sha1Generated"
				echo "     sha1 exists(e): $sha1Exists"
				echo "    sha1 Skipped(s): $sha1Skipped"
				echo ""
				echo "sha256 generated(g): $sha256Generated"
				echo "   sha256 exists(e): $sha256Exists"
				echo "  sha256 Skipped(s): $sha256Skipped"

				tput cup 0 0
			fi

			echo -n "$filename | MD5 ("
			if [ $enable_md5 == true ]; then
				if [ -f "$nestedPath".md5 ]; then
					echo -n "e)"
					((md5Exists++))
				else
					md5sum "$nestedPath" | cut -d " " -f1 > "$nestedPath".md5
					echo -n "g)"
					((md5Generated++))
				fi
			else
				echo -n "s)"
				((md5Skipped++))
			fi
			echo -n " | sha1 ("
			if [ $enable_sha1 == true ]; then
				if [ -f "$nestedPath".sha1 ]; then
					echo -n "e) "
					((sha1Exists++))
				else
					sha1sum "$nestedPath" | cut -d " " -f1 > "$nestedPath".sha1
					echo -n "g)"
					((sha1Generated++))
				fi
			else
				echo -n "s)"
				((sha1Skipped++))
			fi
			echo -n " | sha256 ("
			if [ $enable_sha256 == true ]; then
				if [ -f "$nestedPath".sha256 ]; then
					echo -n "e)"
					((sha256Exists++))
				else
					sha256sum "$nestedPath" | cut -d " " -f1 > "$nestedPath".sha256
					echo -n "g)"
					((sha256Generated++))
				fi
			else
				echo -n "s)"
				((sha256Skipped++))
			fi
			echo " | done"
		fi
		((fileCounter++))
	done <<< "$(eval "find \"$dir\" $findArgs" | sort -t '\0' -n)"

	endTime=`date '+%a %d %b %Y %T %Z'`
	seconds1=$(date +%s)
	seconds2=$(date --date "$startTime" +%s)
	delta=$((seconds1 - seconds2))
	formatedTime=`printf '%dh:%dm:%ds\n' $((delta/3600)) $((delta%3600/60)) $((delta%60))`

	if [ $enable_advanced_display == true ]; then
		tput clear
		tput cup 2 0
	fi

	report_buffer=""

	report_buffer+="Final Report\n"
	report_buffer+="************\n"
	report_buffer+="          Directory: $dir\n"
	report_buffer+="               Mode: $mode\n"
	report_buffer+="         Start Time: $startTime\n"
	report_buffer+="           End Time: $endTime\n"
	report_buffer+="           Duration: $formatedTime\n"
	report_buffer+="    Number of files: $fileCounter\n"
	report_buffer+="\n"
	report_buffer+="   md5 generated(g): $md5Generated\n"
	report_buffer+="      md5 exists(e): $md5Exists\n"
	report_buffer+="     md5 Skipped(s): $md5Skipped\n"
	report_buffer+="\n"
	report_buffer+="  sha1 generated(g): $sha1Generated\n"
	report_buffer+="     sha1 exists(e): $sha1Exists\n"
	report_buffer+="    sha1 Skipped(s): $sha1Skipped\n"
	report_buffer+="\n"
	report_buffer+="sha256 generated(g): $sha256Generated\n"
	report_buffer+="   sha256 exists(e): $sha256Exists\n"
	report_buffer+="  sha256 Skipped(s): $sha256Skipped\n"

	echo -e "$report_buffer"

	if [ $enable_report == true ]; then
		echo -e "$report_buffer\n" >> "$report_location"
	fi
elif [[ $mode == "check" ]]; then
	md5error=false
	md5Good=0
	md5Missing=0
	md5Bad=0
	md5Skipped=0

	sha1error=false
	sha1Good=0
	sha1Missing=0
	sha1Bad=0
	sha1Skipped=0

	sha256error=false
	sha256Good=0
	sha256Missing=0
	sha256Bad=0
	sha256Skipped=0

	while read nestedPath ; do
		if [ -f "$nestedPath" ]; then
			filename="${nestedPath%.*}"

			md5HasError=false
			sha1HasError=false
			sha256HasError=false

			seconds1=$(date +%s)
			seconds2=$(date --date "$startTime" +%s)
			delta=$((seconds1 - seconds2))
			formatedTime=`printf '%dh:%dm:%ds\n' $((delta/3600)) $((delta%3600/60)) $((delta%60))`

			if [ $enable_advanced_display == true ]; then
				# clear first line
				tput cup 0 0
				echo -e "\033[2K"

				# Display report
				tput cup 2 0
				echo "Report (in progress)"
				echo "********************"
				echo "        Directory: $dir"
				echo "             Mode: $mode"
				echo "       Start Time: $startTime"
				echo "         End Time: in progress"
				echo "         Duration: $formatedTime"
				echo "  Number of files: $fileCounter"
				echo ""
				echo "      md5 Good(✓): $md5Good"
				echo "       md5 Bad(X): $md5Bad"
				echo "   md5 Missing(?): $md5Missing"
				echo "   md5 Skipped(s): $md5Skipped"
				echo ""
				echo "     sha1 Good(✓): $sha1Good"
				echo "      sha1 Bad(X): $sha1Bad"
				echo "  sha1 Missing(?): $sha1Missing"
				echo "  sha1 Skipped(s): $sha1Skipped"
				echo ""
				echo "   sha256 Good(✓): $sha256Good"
				echo "    sha256 Bad(X): $sha256Bad"
				echo "sha256 Missing(?): $sha256Missing"
				echo "sha256 Skipped(s): $sha256Skipped"

				tput cup 0 0
			fi
			echo -n "$nestedPath | "
			echo -n "MD5 ("
			if [ $enable_md5 == true ]; then
				md5Filename="$nestedPath".md5
				if [ -f "$md5Filename" ]; then
					if [ "$findMissing" == "false" ]; then
						md5Contents=`cat "$md5Filename"`
						md5Sum=`md5sum "$nestedPath" | cut -d " " -f1`
						if [ "$md5Contents" == "$md5Sum" ]; then
							echo -n "✓) "
							((md5Good++))
						else
							echo -n "X) "
							((md5Bad++))
							md5HasError=true
						fi
					fi
				else
					echo -n "?) "
					md5HasError=true
					((md5Missing++))
				fi
			else
				echo -n "s) "
				((md5Skipped++))
			fi

			echo -n "| sha1 ("
			if [ $enable_sha1 == true ]; then
				sha1Filename="$nestedPath".sha1
				if [ -f "$sha1Filename" ]; then
					if [ "$findMissing" == "false" ]; then
						sha1Contents=`cat "$sha1Filename"`
						sha1Sum=`sha1sum "$nestedPath" | cut -d " " -f1`
						if [ "$sha1Contents" == "$sha1Sum" ]; then
							echo -n "✓) "
							((sha1Good++))
						else
							echo -n "X) "
							((sha1Bad++))
							sha1HasError=true
						fi
					fi
				else
					echo -n "?) "
					((sha1Missing++))
					sha1HasError=true
				fi
			else
				echo -n "s) "
				((sha1Skipped++))
			fi

			echo -n "| sha256 ("
			if [ $enable_sha256 == true ]; then
				sha256Filename="$nestedPath".sha256
				if [ -f "$sha256Filename" ]; then
					if [ "$findMissing" == "false" ]; then
						sha256Contents=`cat "$sha256Filename"`
						sha256Sum=`sha256sum "$nestedPath" | cut -d " " -f1`
						if [ "$sha256Contents" == "$sha256Sum" ]; then
							echo -n "✓) "
							((sha256Good++))
						else
							echo -n "X) "
							((sha256Bad++))
							sha256HasError=true
						fi
					fi
				else
					echo -n "?) "
					((sha256Missing++))
					sha256HasError=true
				fi
			else
				echo -n "s) "
				((sha256Skipped++))
			fi

			echo "| done"

			if [ $md5HasError == "true" ] || [ $sha1HasError == "true" ] || [ $sha256HasError == "true" ]; then
				error_log="$error_log$nestedPath\n"
			fi

			((fileCounter++))
		fi

	done <<< "$(eval "find \"$dir\" $findArgs" | sort -t '\0' -n)"
	echo "done"

	endTime=`date '+%a %d %b %Y %T %Z'`
	seconds1=$(date --date "$endTime" +%s)
	seconds2=$(date --date "$startTime" +%s)
	delta=$((seconds1 - seconds2))
	formatedTime=`printf '%dh:%dm:%ds\n' $((delta/3600)) $((delta%3600/60)) $((delta%60))`

	if [ $enable_advanced_display == true ]; then
		tput clear
		tput cup 0 0
	fi

	report_buffer=""

	report_buffer+="Final Report\n"
	report_buffer+="************\n"
	report_buffer+="        Directory: $dir\n"
	report_buffer+="             Mode: $mode\n"
	report_buffer+="       Start Time: $startTime\n"
	report_buffer+="         End Time: $endTime\n"
	report_buffer+="         Duration: $formatedTime\n"
	report_buffer+="  Number of files: $fileCounter\n"
	report_buffer+="\n"
	report_buffer+="      md5 Good(✓): $md5Good\n"
	report_buffer+="       md5 Bad(X): $md5Bad\n"
	report_buffer+="   md5 Missing(?): $md5Missing\n"
	report_buffer+="   md5 Skipped(s): $md5Skipped\n"
	report_buffer+="\n"
	report_buffer+="     sha1 Good(✓): $sha1Good\n"
	report_buffer+="      sha1 Bad(X): $sha1Bad\n"
	report_buffer+="  sha1 Missing(?): $sha1Missing\n"
	report_buffer+="  sha1 Skipped(s): $sha1Skipped\n"
	report_buffer+="\n"
	report_buffer+="   sha256 Good(✓): $sha256Good\n"
	report_buffer+="    sha256 Bad(X): $sha256Bad\n"
	report_buffer+="sha256 Missing(?): $sha256Missing\n"
	report_buffer+="sha256 Skipped(s): $sha256Skipped\n"
	report_buffer+="\n"

	bad=$(($md5Bad + $sha1Bad + $sha256Bad + md5Missing + sha1Missing + sha256Missing))

	if [ "$bad" -eq "0" ]; then
		report_buffer+="  ** All good **"
	else
		report_buffer+="  !!! Some errors should investigate !!!\n\n"
		report_buffer+="$error_log"
	fi

	echo -e "$report_buffer"

	if [ $enable_report == true ]; then
		echo -e "$report_buffer\n" >> "$report_location"
	fi
elif [[ $mode == "update" ]]; then
	fullpath=$(readlink -f "${BASH_SOURCE}")
	installDir=${fullpath%/*}
	filename=${fullpath:$(( ${#installDir} + 1 )):${#fullpath}}

	echo "Updating $installDir/$filename:"
	curl https://raw.githubusercontent.com/stevenharradine/bashInstaller/master/installer.sh | bash -s "installDir=$installDir" program=hasher
elif [[ $mode == "help" ]]; then
	echo "hasher version $HASHER_VERSION"
	echo "./hasher.sh [options]"
	echo ""
	echo "  options:"
	echo "    --mode=(create, check) what mode to run hasher in"
	echo "    --directory=the directory you want hasher to run against"
	echo "    --enable-md5={true|false}"
	echo "    --enable-sha1={true|false}"
	echo "    --enable-sha256={true|false}"
	echo "    --find-missing={true|false}, do not scan the files but just look for missing hashes"
	echo "    --enable-report={true|false}, write the final report to the --report-location"
	echo "    --report-location=the location to write the final report when --enable-report flag is set to true"
	echo "    --update, update this program with the lastest version from git"
	echo "    --help, -h, -? Will enable this help window"
	echo ""
	echo "usage: ./hasher.sh --mode=create --directory=/home/pi/videos --enable-md5=false"
else
	echo "'mode' not definded"
	echo ""
	echo "try: ./hasher.sh --help"
fi
