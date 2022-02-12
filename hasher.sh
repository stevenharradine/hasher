#!/bin/bash
mode=help
dir="./"
filetypes_videos=(avi mkv mp4 ts mts m2ts mpg mpeg wmv wv flv webm vob ogv ogg rm asf)
filetypes_images=(jpeg jpg gif bmp svg)
filetypes_audio=(mp3 flac wav)
filetypes_documents=(txt doc docx pdf xls odf xlsx)
filetypes=$filetypes_videos
startTime=`date '+%a %d %b %Y %T %Z'`
findArgs=""
enable_md5=true
enable_sha1=true
enable_sha256=true
fileCounter=0

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
tput clear

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

	tput clear
	tput cup 2 0

	echo "Final Report"
	echo "************"
	echo "          Directory: $dir"
	echo "               Mode: $mode"
	echo "         Start Time: $startTime"
	echo "           End Time: $endTime"
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
			echo -n "$nestedPath | "
			echo -n "MD5 ("
			if [ $enable_md5 == true ]; then
				md5Filename="$nestedPath".md5
				if [ -f "$md5Filename" ]; then
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

			if [ $md5HasError ] || [ $sha1HasError ] || [ $sha256HasError ]; then
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

	tput clear
	tput cup 0 0

	echo ""
	echo "Final Report"
	echo "************"
	echo "        Directory: $dir"
	echo "             Mode: $mode"
	echo "       Start Time: $startTime"
	echo "         End Time: $endTime"
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
	echo ""

	bad=$(($md5Bad + $sha1Bad + $sha256Bad))

	if [ "$bad" -eq "0" ]; then
		echo "  ** All good **"
	else
		echo "  !!! Some errors should investigate !!!"
		echo -e "$error_log"
	fi
elif [[ $mode == "help" ]]; then
	echo "hasher version 0.2"
	echo "./hasher.sh [options]"
	echo ""
	echo "  options:"
	echo "    --mode=(create, check, help) what mode to run hasher in"
	echo "    --directory=the directory you want hasher to run against"
	echo "    --enable-md5={true|false}"
	echo "    --enable-sha1={true|false}"
	echo "    --enable-sha256={true|false}"
	echo "    --help, -h, -? Will enable this help window"
	echo ""
	echo "usage: ./hasher.sh --mode=create --directory=/home/pi/videos --enable-md5=false"
else
	echo "'mode' not definded"
	echo ""
	echo "try: ./hasher.sh --help"
fi
