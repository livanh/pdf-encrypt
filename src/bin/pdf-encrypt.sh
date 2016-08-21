#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

INFILE="$1"

# select program to ask for password
if [ $(which gtk-led-askpass) ]; then
	PASSWORD_COMMAND="gtk-led-askpass"
	PASSWORD_COMMAND_ARG1=""
	PASSWORD_COMMAND_ARG2=""
elif [ $(which zenity) ]; then
	PASSWORD_COMMAND="zenity"
	PASSWORD_COMMAND_ARG1=--password
	PASSWORD_COMMAND_ARG2=--title
else
	echo "Error: zenity not found!"
	exit 1
fi

# check if file is encrypted
qpdf --show-encryption "$INFILE" 1>/dev/null 2>/dev/null
case $? in
	0) echo File is not encrypted; OLD_PASSWORD=;;
	2) echo File is encrypted;
		qpdf --show-encryption "$INFILE" 1>/dev/null 2>/dev/null
		while [ $? == 2 ]; do
			OLD_PASSWORD="--password=$(${PASSWORD_COMMAND} ${PASSWORD_COMMAND_ARG1} ${PASSWORD_COMMAND_ARG2} "Old password")"
			if [ $? == 1 ]; then exit; fi;
			qpdf $OLD_PASSWORD --show-encryption "$INFILE" 1>/dev/null 2>/dev/null
		done;;
	*) echo Error checking file encryption; zenity --warning --text "Error checking file encryption" --title "pdf-encrypt"; exit;;
esac

# encrypt file
NEW_PASSWORD_1="$(${PASSWORD_COMMAND} ${PASSWORD_COMMAND_ARG1} ${PASSWORD_COMMAND_ARG2} "New password:")"
if [ $? == 1 ]; then exit; fi
NEW_PASSWORD_2="$(${PASSWORD_COMMAND} ${PASSWORD_COMMAND_ARG1} ${PASSWORD_COMMAND_ARG2} "Confirm new password:")"
if [ $? == 1 ]; then exit; fi
if [ "$NEW_PASSWORD_1" == "$NEW_PASSWORD_2" ]; then
	OUTFILE="$(zenity --file-selection --save --confirm-overwrite --filename="$INFILE")"
	if [ $? == 1 ]; then exit; fi
	while [ "$OUTFILE" == "$INFILE" ]; do
		echo Input and output file can\'t be the same
		zenity --warning --text "Input and output file can\'t be the same" --title "pdf-encrypt";
		OUTFILE="$(zenity --file-selection --save --confirm-overwrite --filename="$INFILE")"
		if [ $? == 1 ]; then exit; fi
	done
	qpdf $OLD_PASSWORD --encrypt "$NEW_PASSWORD_1" "$NEW_PASSWORD_1" 128 -- "$INFILE" "$OUTFILE"

	case $? in
		0) echo Encryption completed;               zenity --info    --text "Encryption completed"               --title "pdf-encrypt";;
		*) echo An error occured during encryption; zenity --warning --text "An error occured during encryption" --title "pdf-encrypt";;
	esac
else
	echo Entered passwords don\'t match
	zenity --warning --text "Entered passwords don\'t match" --title "pdf-encrypt";
fi
