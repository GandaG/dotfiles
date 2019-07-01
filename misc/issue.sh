#!/usr/bin/sh

{
  echo "Arch Linux \\m \\r (\\l)";
  echo ;
  echo "$(fortune -s anti-jokes | cowsay -n)" | sed "s \\\ \\\\\\\ g";
  echo ;
} > /etc/issue
