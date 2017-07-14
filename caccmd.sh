#!/bin/bash
#cloudatcost command for api v1
#function list
#/api/v1/listservers.php
#/api/v1/listtemplates.php
#/api/v1/listtasks.php
#/api/v1/powerop.php
#/api/v1/renameserver.php
#/api/v1/rdns.php
#/api/v1/console.php
#/api/v1/runmode.php
#/api/v1/cloudpro/build.php
#/api/v1/cloudpro/delete.php
#/api/v1/cloudpro/resources.php

#KEY=yourkey
#LOGIN=yourlogin
resjson=/tmp/cac/res.json
cpu_total=0
ram_total=0
storage_total=0
cpu_used=0
ram_used=0
storage_used=0
cpu_free=0
ram_free=0
storage_free=0
faillist=cacfail.list

PANEL="https://panel.cloudatcost.com"
CMDLS=$PANEL/api/v1/listservers.php
CMDLST=$PANEL/api/v1/listtemplates.php
CMDTASK=$PANEL/api/v1/listtasks.php
CMDPW=$PANEL/api/v1/powerop.php
CMDREN=$PANEL/api/v1/renameserver.php
CMDRDNS=$PANEL/api/v1/rdns.php
CMDCON=$PANEL/api/v1/console.php
CMDMODE=$PANEL/api/v1/runmode.php
CMDBUILD=$PANEL/api/v1/cloudpro/build.php
CMDDEL=$PANEL/api/v1/cloudpro/delete.php
CMDRES=$PANEL/api/v1/cloudpro/resources.php

function cac_ls()
{
	curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq '.'
}

function cac_lsp()
{
	curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq '.data[] | select (.status == "Pending")'
}

function cac_lsn()
{
	patten=$1
	if test -z "$patten";
	then
		curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq ".data[] | .sid | tonumber" | sed 's/"//g'
	else
		curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq ".data[] | select (.status == \"$1\") | .sid | tonumber" | sed 's/"//g'
	fi
}

function cac_lsg()
{
	patten=$1
	if test -z "$patten";
	then
		curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq ".data[] | .portgroup" | sed 's/"//g'
	else
		curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq ".data[] | select (.status == \"$1\") | .portgroup" | sed 's/"//g'
	fi
}

function cac_lspn()
{
	curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq '.data[] | select (.status == "Pending") | .sid | tonumber'
}

function cac_lsi()
{
	curl -s "https://panel.cloudatcost.com/api/v1/listservers.php?key=${KEY}&login=${LOGIN}" | jq '.data[] | select (.status == "Installing")'
}

function cac_lst()
{
	curl -s "https://panel.cloudatcost.com/api/v1/listtemplates.php?key=${KEY}&login=${LOGIN}" | jq '.'
}

function cac_task()
{
	curl -s "https://panel.cloudatcost.com/api/v1/listtasks.php?key=${KEY}&login=${LOGIN}" | jq '.'
}

function cac_pw()
{
	curl -s --data "key=${KEY}&login=${LOGIN}&sid=${1}&action=${2}" https://panel.cloudatcost.com/api/v1/powerop.php | jq '.'
}

function cac_mode()
{
	curl -s --data "key=${KEY}&login=${LOGIN}&sid=${1}&mode=${2}" https://panel.cloudatcost.com/api/v1/runmode.php | jq '.'
}

function cac_ren()
{
	curl -s --data "key=${KEY}&login=${LOGIN}&sid=${1}&name=${2}" https://panel.cloudatcost.com/api/v1/renameserver.php | jq '.'
}

function cac_rdns()
{
	curl -s --data "key=${KEY}&login=${LOGIN}&sid=${1}&hostname=${2}" https://panel.cloudatcost.com/api/v1/rdns.php | jq '.'
}

function cac_build()
{
	curl -s --data "key=${KEY}&login=${LOGIN}&cpu=${1}&ram=${2}&storage=${3}&os=${4}" https://panel.cloudatcost.com/api/v1/cloudpro/build.php | jq '.'
}

function cac_console()
{
	curl -s --data "key=${KEY}&login=${LOGIN}&sid=${1}" https://panel.cloudatcost.com/api/v1/console.php
}

function cac_del()
{
	curl -s --data "key=${KEY}&login=${LOGIN}&sid=${1}" https://panel.cloudatcost.com/api/v1/cloudpro/delete.php | jq '.'
}

function cac_res()
{
	curl -s "https://panel.cloudatcost.com/api/v1/cloudpro/resources.php?key=${KEY}&login=${LOGIN}" | jq '.'
}

function cac_resfree()
{
	curl -s "https://panel.cloudatcost.com/api/v1/cloudpro/resources.php?key=${KEY}&login=${LOGIN}" | jq '[(.data.total.cpu_total | try tonumber catch 0)-(.data.used.cpu_used | try tonumber catch 0),(.data.total.ram_total | try tonumber catch 0)-(.data.used.ram_used | try tonumber catch 0),(.data.total.storage_total | try tonumber catch 0)-(.data.used.storage_used | try tonumber catch 0)] | map(tostring) | join(",")' -c | sed 's/"//g'  | sed 's/,/ /g'
}

function cac_init()
{
	read -p "Please INPUT APIKEY(default is $KEY): " tmpkey
	test -z $tmpkey || KEY=$tmpkey
	read -p "Please INPUT login(default is $LOGIN): " tmplogin
	test -z $tmplogin || LOGIN=$tmplogin
	echo APIKEY:$KEY 
	echo login:$LOGIN
}

function cac_con()
{
#
cac_init
#list
}

function cac_loop()
{
	SDELAY=$1
	state="doing"
	for ((i = 1; i <= 500000; i++))
	do
		RMSRV=`cac_lspn`
		cac_pw $RMSRV poweron
		#sleep 2
		#cac_pw $RMSRV poweroff
		cac_del $RMSRV
		cac_build 1 512 10 3
		#sleep 5
		cac_lsp
		RMSRV=`cac_lspn`
		if test -z "${RMSRV}" ;
		then
			state="done"
			echo $i : $state $RMSRV `cac_ls | jq '.data[] | select (.status == "Installing") | .sid | tonumber'`
			break
		else
			echo $i : $state $RMSRV
		fi
		sleep $SDELAY
	done
}

function cac_rebuildpending ()
{
	PSRV=`cac_lspn`;echo "sid:"$PSRV;cac_pw $PSRV poweron | jq '["poweron:",.status]| join ("")';cac_del $PSRV| jq '["delete:",.status]| join ("")';
	cac_build `cac_resfree` 3 | jq '["buid:",.result]| join ("")'
	date -u
	cac_lsp | jq '{"server":.sid,"group":.portgroup,"status":.status}'
}

function cac_rbl ()
{
	DELAY=$1
	for ((i = 1; i <= 500000; i++))
	do
		#remove fail
		#get free res
			#no free res break
		#build
		#check blacklist
			#then remove pending ; continue
			#else go on
		#wait
		#check server state timeout
			#blacklist timeout server portgroup,remove pending
		#
		cac_rebuildpending
		sleep $DELAY
		RMSRV=`cac_lspn`
		if test -z "${RMSRV}" ;
		then
			state="done"
			echo $i : $state
			cas_ls
			break
		else
			echo $i : $state $RMSRV
		fi
		ISBL=`cac_chkblacklist`
		#if test -z "$ISBL";
		#else
		#fi
		sleep $SDELAY
		#checkfail
		SFAIL=`cac_dtcfail`
		if test -z "$SFAIL";
		then
			continue
		else
			echo "$SFAIL" >> $faillist
			cac_del `cac_lsn Fail`
		fi
	done
}

function cac_loop2 ()
{
	DELAY=$1
	for ((i = 1; i <= 500000; i++))
	do
		cac_loop $DELAY
		cac_del `cac_lsn Failed`
		sleep $DELAY
	done
}

function cac_chkblacklist ()
{
	cat cacfail.list | grep $1 -c
}

function cac_chkfail ()
{
	echo $
	cut $faillist
}

function cac_dtcfail ()
{
	cac_ls | jq '.data[] | select (.status == "Failed")| [.status,.sid,.portgroup] | join(",")' -c | sed 's/"//g'  | sed 's/,/ /g'
}

function cac_lsdn ()
{
	cac_ls| jq ".data[] | select (.sdate == \"$1\") | .sid | tonumber"
}

function cac_lsd ()
{
	cac_ls| jq ".data[] | select (.sdate == \"$1\")"
}

function cac_lsn ()
{
	cac_ls| jq ".data[] | select (.lable == \"$1\")"
}

function cac_setkey()
{
LOGIN=$1
KEY=$2
}
