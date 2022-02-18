#!/bin/bash
echo "I am your Help"
echo "------------------"
echo "Choose your Emergency"
echo "1. Accident"
echo "2. Mental Stress"
echo "3. Sexual Assault"
read number
echo "------------------"
echo "What you want to do?"
echo "1. Get Emergency Contact Number"
echo "2. Open its website"
read option

if [[ ( $number == "1" && $option == "1" ) ]]
then
    echo "Call Anbulance 108"
elif [[ ( $number == "1" && $option == "2" ) ]]
then
    google-chrome http://www.rajswasthya.nic.in/EMRI.htm
elif [[ ( $number == "2" && $option == "1" ) ]]
then
    echo "Call 1800 011 511"
elif [[ ( $number == "2" && $option == "2" ) ]]
then
    google-chrome https://www.health.nsw.gov.au/mentalhealth/Pages/mental-health-line.aspx
elif [[ ( $number == "3" && $option == "1" ) ]]
then
    echo "Call Police 100"
    echo "Call 1800 330 0226"
elif [[ ( $number == "3" && $option == "2" ) ]]
then
    google-chrome https://www.healthdirect.gov.au/sexual-assault-and-rape 
else
    echo "Error! Try again"
fi
