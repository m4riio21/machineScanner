#!/bin/bash

#Global variables
ip=$(ifconfig | grep tun -A 1 | grep "inet" | awk -F' ' '{print $2}')
numDependencies=2

#Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
 
trap ctrl_c INT
 
function ctrl_c(){
    clear
    echo -e "\n${red}[!] Saliendo...\n${end}"
    tput cnorm; exit 1
}



function helpPanel(){
	clear
	tput civis
	echo -e "\n${yellow}[!]${end}${gray}Modo de uso${end}"
	echo -e "\n\n\t${blue}[-i]${end} Indicar la IP de la maquina a escanear ${end}"
	echo -e "\n\n\t${blue}[-h]${end} Mostrar este panel de ayuda ${end}\n"
	sleep 2
	tput cnorm
}

function machineScan(){
	if [ "$(whoami)" == "root" ]; then
		checkIp=$1
		allPorts=""
		clear
		tput civis
		echo -ne "${yellow}[*]${end}${blue} Comprobando que la OVPN esté desplegada"
		sleep 0.5; echo -ne "."; sleep 0.5; echo -ne "."; sleep 0.5; echo -ne "."; sleep 1

		if [ "$ip" ]; then
			numOk=0
			echo -e "\t${green}[V]${end}"
			sleep 2
			echo -e "\n${yellow}[*]${end}${blue} Comprobando dependencias"
			sleep 1
			echo -ne "\n${gray}nmap"; sleep 0.25; nmap=$(which nmap); if [ $(echo $? -eq "0") ]; then let numOk+=1; echo -e "\t${green}[V]${end}"; else echo -e "\t${red}[X]${end}"; fi
			sleep 1
			echo -ne "\n${gray}searchsploit"; sleep 0.25; nmap=$(which searchsploit); if [ $(echo $? -eq "0") ]; then let numOk+=1; echo -e "\t${green}[V]${end}"; else echo -e "\t${red}[X]${end}"; fi
			sleep 1
			if [ $numOk == $numDependencies ]; then
				clear
				sleep 0.25
				echo -e "\n${yellow}[*]${end}${blue} Comenzando la fase de reconocimiento"
				ports=$(nmap -p- -sS --min-rate 5000 --open -T5 -n $checkIp | grep tcp | tr '/' ' ' | awk -F' ' '{print $1}' | xargs)

				for port in $ports; do
					allPorts=$allPorts$port","
				done
				clear
				ports=$(echo $allPorts | sed s'/.$//')
				echo -e "\n${yellow}[*]${end}${blue} Escaneo NMAP a la maquina $checkIp\n\n"
				nmap -p"$ports" -sC -sV $checkIp | awk '/PORT/,/Nmap done/' 
				echo -e "\n"
				
			fi
		else
			echo -e "\t${red}[X]${end}"
		fi



		tput cnorm
	else
		echo -e "\n\n${red} [!] Ejecuta el programa en modo root ${end}\n"
	fi

}

#Main
declare -i parameter_counter=0; while getopts "i:h:" arg; do
	case $arg in
		i) ipscan=$OPTARG; let parameter_counter+=1;;
		h) helpPanel;;
	esac
done

if [ $parameter_counter -eq "0" ]; then
	helpPanel
else
	machineScan $ipscan
fi
