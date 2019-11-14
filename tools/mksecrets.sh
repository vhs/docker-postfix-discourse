#!/bin/bash

cd $(dirname $0)/..

if [ ! -f config ] ; then
	echo "Missing config file. Please set config."
	exit
fi

if [ ! -d ./secrets ] ; then
	echo "Missing secrets directory. Creating..."
	mkdir ./secrets
fi

#
# Defaults
#
FORCE=0

#
# Parse arguments
#
for OPT in $@ ; do
	case $OPT in
	--force | -f)
		FORCE=1
		;;
	*)
		echo "Unknown option $OPT"
		echo ""
		echo "$(basename $0) [--force|-f]"
		echo ""
		exit
		;;
	esac
done

#
# Set the secrets
#
cat config | sed 's/\ #.*$//g' | egrep -v '^($|#|;)' | while read SECRET
do
	ENVKEY=$(echo "$SECRET" | cut -f1 -d=)
	ENVVAL=$(echo "$SECRET" | cut -f2 -d=)

	SECRET_FILE=$(echo "./secrets/$ENVKEY")

	if [ ! -f $SECRET_FILE ] ; then
		echo "Creating $ENVKEY file..."
		echo "$ENVVAL" > $SECRET_FILE
	else
		if [ $FORCE -eq 1 ] ; then
			echo "Updating $ENVKEY file..."
			echo "$ENVVAL" > $SECRET_FILE
		else
			echo "Skipping $ENVKEY file..."
		fi
	fi
done
