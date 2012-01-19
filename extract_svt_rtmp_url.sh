#!/bin/sh

# This script is a quick hack to extract the rtmp url from a svtplay stream.
#
# If you got here via a search engine you are probably lost and
# should instead go to:
#
#  http://svtget.se/
#
# Svtget has a more potent script. This one only extracts the highest
# bitrate (2400 kbps) stream and, if succesful, prints out a command
# that hypothetically could be used to download that stream.
#
# I wrote this because the svtget bash script didn't work on mac osx.
# Probably because osx uses another version of sed (and bash). For
# portability's sake this script uses a more universal sed syntax
# that works out on both mac osx, GNU/Linux and maybe the local gym too.
# It is also written in the ancient bourne shell syntax in order to
# be compatible with all (if not more) *nix dialects.
#
# I do not encourage anyone to download streams from svtplay. But if
# you decide to go wild and crazy and do it anyway it might be good
# to read The Disclaimer Below.
#
#
# The Disclaimer Below
#
# It is legal to download streams from svtplay for private use as
# long as you pay the Radiotjänst TV-avgift. But you may NOT distribute
# these inspelningar to someone who doesn't pay the Radiotjänst TV-avgift.
# If you do you may be violating brottskod 5101 (which just happens to
# be worse than terrorism).
#
#
# All Rights Reversed - No Rights Reserved.
#
#
# - Pungenday, the 18th day of Chaos in the YOLD 3178 (disc)
# - January 18 2012 (greg)
# - Nonidi, 29 Nivôse CCXX (frc)
# - January 5 2012 (jul)
#
# Albert Veli
#
#
# After this boring introduction, over to something more interesting...
#
# The code:

# Check if hypothetical user gave argument
if test -z "${1}"; then
	echo "Usage: ${0} <svtplay url>"
	exit 1
fi

# Get page html code.
if test -x "`which curl`"; then
	HTML=`curl -s "${1}"`
else
	if test -x "`which wget`"; then
		HTML=`wget -qO- "${1}"`
	else
		echo " --> Error: either curl or wget must be installed"
		exit 1
	fi
fi

# Only parse the highest bitrate (2400 kbps) url
tcUrl=`echo "${HTML}" | sed -n 's/.*url:\(rtmp[e]*:[^:]*\):2400.*/\1/gp' | sed 's/,bitrate//' | uniq`
if test -z "${tcUrl}"; then
	# Hypothetical user did something wrong (or maybe svtplay changed)
	echo ""
	echo " --> Error: failed to extract 2400 kbps url"
	echo ""
	echo "probably one of the following errors:"
	echo " - Wrong url (did you take it from svtplay.se? really?)"
	echo " - No 2400 kbps stream available"
	echo " - Connection error / timeout"
	echo " - Syntax change in svtplay html (alert the person behind you)"
	exit 1
fi

# Get shockwave flash player url
swfUrl=`echo "${HTML}" | sed -n 's/.*x-shockwave-flash\" data=\"\(\/flash\/svtplayer-[0-9]*\.[0-9]*\.swf\).*/http:\/\/svtplay.se\1/p'`
if test -z "${swfUrl}"; then
	# Huh? How could tcUrl work and not this?
	echo " --> Error: failed to extract swf player url"
	exit 1
fi

# Take output filename from input svtplay url ($1)
output=`echo "${1}" | sed 's/?.*//' | sed 's/.*\/\(.*\)/\1.mp4/'`
if test -z "${output}"; then
	# Failed to parse output name.
	# Not a good omen... but try with output.mp4 anyway.
	output="output.mp4"
fi

# Echo the dangerous command - that hypothetically, in the near
# future, could be used to infringe brottskod 5101 - to the console.
echo ""
echo "rtmpdump -r \"${tcUrl}\" --swfVfy=\"${swfUrl}\" -o \"${output}\""
echo ""

# Epic success
exit 0

