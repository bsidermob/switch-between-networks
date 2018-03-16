#!/bin/bash

# add networkservice to sudoers

# Find out how many services are on the device
numberOfServices=$(networksetup -listnetworkserviceorder | cut -d')' -f2 | sed '/^$/d' | sed '1d' | sed -e 's/^[ \t]*//' | wc -l)

# Remove temp file
rm -rf temp_wifi
mkdir temp_wifi
cd temp_wifi

# Save each service into text file
for ((i=1; i<=$numberOfServices; i++))
do
  service=$(networksetup -listnetworkserviceorder | cut -d')' -f2 | sed '/^$/d' | sed '1d' | sed -e 's/^[ \t]*//' | awk NR==${i})
  echo -e "\x22$service\x22" >> interfaces.txt
done

# Switch service order if the first service isn't Wi-Fi
active_service=$(cat interfaces.txt | awk NR==1)
if [ "$active_service" != '"Wi-Fi"' ]
then
  echo "Active service isn't Wi-Fi. Switching to Wi-Fi."
  #Strip Wi-Fi out of interfaces list
  grep -vF '"Wi-Fi"' interfaces.txt > new_interfaces.txt
  #Prepend Wi-Fi as the first interface
  #awk '{print "Wi-Fi "$0}' new_interfaces.txt > new_interfaces2.txt
  awk 'BEGIN{print "\x22Wi-Fi\x22"}{print}' new_interfaces.txt > new_interfaces2.txt
  # add quotes to interfaces.txt
  #awk '{ print "\""$0"\""}' new_interfaces2.txt > interfaces_quoted.txt
  interfaces_in_one_line=$(awk '{printf "%s ",$0} END {print ""}' new_interfaces2.txt)
  # echo $interfaces_in_one_line
  # Switch network order
  bash -c "sudo networksetup -ordernetworkservices $interfaces_in_one_line"
else
  echo "Active Service seems to be Wi-Fi. Switching to 802.11n"
  #Strip 802.11n NIC out of interfaces list
  grep -vF '"802.11n NIC"' interfaces.txt > new_interfaces.txt
  #Prepend
  awk 'BEGIN{print "\"802.11n NIC\""}{print}' new_interfaces.txt > new_interfaces2.txt
  interfaces_in_one_line=$(awk '{printf "%s ",$0} END {print ""}' new_interfaces2.txt)
  # Switch network order
  bash -c "sudo networksetup -ordernetworkservices $interfaces_in_one_line"
  # sudo networksetup -ordernetworkservices "Wi-Fi" "802.11n NIC" "Thunderbolt Ethernet" "Dell Universal Dock D6000" "Bluetooth PAN" "Thunderbolt Bridge"
  # sudo networksetup -ordernetworkservices "802.11n NIC" "Wi-Fi" "Thunderbolt Ethernet" "Dell Universal Dock D6000" "Bluetooth PAN" "Thunderbolt Bridge"
fi
