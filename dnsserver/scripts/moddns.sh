#!/bin/bash

while getopts 'p:i:h:d:k:t:' opt; do
  case $opt in
    p) PATHEN="$OPTARG" #Path till katalog med konfig: deafult: /etc/named
    ;;
    i) IP="$OPTARG"
    ;;
    h) HOST="$OPTARG"
    ;;
    d) DOMN="$OPTARG"
    ;;
    k) KOMMENTAR="$OPTARG"
    ;;
    t) TABORT="$OPTARG" #true att ta bort
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

function nySerial {
    OLSRL=$(grep serial $1 |awk '{print $1}')
    LPNR=$(expr ${OLSRL: +8} + 1)

    if [ $LPNR -lt 100 ]; then
        NYSRL=$(date +"%Y%m%d")$LPNR
    else
        NYSRL=$(date +"%Y%m%d1")
    fi
    sed -i "s/[0-9].*\;.*serial$/\t${NYSRL}\t\;\tserial/" $1
}

if [ "$PATHEN" = "" ]; then
    PATHEN="/etc/named" 
fi

NTVRK=$(echo $IP|awk '{ split($1,a,"."); print a[1]"."a[2]"."a[3]; }')
RNTVRK=$(echo $IP|awk '{ split($1,a,"."); print a[3]"."a[2]"."a[1]; }')
ID=$(echo $IP|awk '{ split($1,a,"."); print a[4]; }')
FRWRD=$PATHEN/$DOMN.zone
REVRS=$PATHEN/$NTVRK.zone

if [ "$TABORT" = true ]; then
    echo "Tar bort ${HOST} ur ${FRWRD}..."
    nySerial $FRWRD
    sed -i "s/^$HOST\.[a-z].*//" $FRWRD

    echo "Tar bort ${HOST} ur ${REVRS}..."
    nySerial $REVRS
    sed -i "s/^[1-9].*$HOST\.[a-z].*//" $REVRS
else
    if $(grep -q $HOST $FRWRD) ; then
        echo "Hosten finns redan i ${FRWRD}..."
    else
        echo "Lägger till $HOST i ${FRWRS}..."
        nySerial $FRWRD
        printf "${HOST}\tIN\tA\t${IP}\t;${KOMMENTAR}\n" >> $FRWRD
    fi


    if $(grep -q "^${ID}.*IN" $REVRS) ; then
        echo "Numret finns redan i ${REVRS}..."
    else
        echo "Lägger till $HOST i ${REVRS}..."
        nySerial $REVRS
        printf "${ID}\tIN\tPTR\t${HOST}.$DOMN.\t\n" >> $REVRS
    fi
fi

named-checkzone -q $DOMN $FRWRD
if [ $? -ne 0 ]; then 
    echo "zonkonfen för ${FRWRD} validerar inte... kontrollera innehållet"
    exit 1
fi

named-checkzone -q $RNTVRK.in-addr.arpa $REVRS 
if [ $? -ne 0 ]; then 
    echo "zonkonfen för ${REVRS} validerar inte... kontrollera innehållet"
    exit 1
else 
    echo "zonkonfen validerar starta om containern...(manuellt)"
fi
