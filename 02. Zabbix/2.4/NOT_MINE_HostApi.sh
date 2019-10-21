#!/bin/bash
 
source /vagrant/variables.conf

#getting API token
curlAuth=`curl -sS -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"password\": \"$zPass\", \"user\": \"$zUser\"}, \"jsonrpc\":\"2.0\", \"method\": \"user.login\", \"id\": 0}" $zApi`

authToken=`echo $curlAuth | grep -o -P '(?<=result":").*(?=","id")'`
#Creating Host Group CloudHosts
curlDataGroup="
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostgroup.create\",
    \"params\": {
        \"name\": \"$zGroupName\"
    },
    \"auth\": \"$authToken\",
    \"id\": 1
}
"

curlGroupCr=`curl -sS -i -X POST -H "Content-Type: application/json-rpc" -d "$curlDataGroup" $zApi`

#getting groupId for CloudHosts
zGroupId=`echo $curlGroupCr | grep -o -P '(?<=groupids":\[").*(?="\]\},"id)'`

#Creating Template "My Custom Template"
curlTempData="
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"template.create\",
    \"params\": {
        \"host\": \"My Custom Template\",
        \"groups\": {
            \"groupid\": \"$zGroupId\"
        }
        
    },
    \"auth\": \"$authToken\",
    \"id\": 1
}
"


curlTempCr=`curl -sS -i -X POST -H "Content-Type: application/json-rpc" -d "$curlTempData" $zApi`

#getting templateId for My Custom Template
zTemplateId=`echo $curlTempCr | grep -o -P '(?<=templateids":\[").*(?="\]\},"id)'`

#Creating Host "zabbixclient"
curlDataHost="
{
	\"jsonrpc\":\"2.0\",
	\"method\":\"host.create\"
	,\"params\":{
		\"host\":\"$zHost\",
		\"interfaces\": [
			{
				\"type\":1
				,\"main\":1,
				\"useip\":1,
				\"ip\":\"$zHostIp\",
				\"dns\":\"\",
				\"port\":\"$zPort\"
			}
		],
		\"groups\":[
			{
				\"groupid\":\"$zGroupId\"
			}
		],\"templates\":  [
			{	
				
				\"templateid\":\"$zTemplateId\"
					
			},
			{
				\"templateid\":\"10001\"
			}
		
		]
	},
	\"auth\":\"$authToken\",
	\"id\":1
}
"

curlHostCr=`curl -sS -i -X POST -H "Content-Type: application/json-rpc" -d "$curlDataHost" $zApi`
zUserId=`echo $curlTempCr | grep -o -P '(?<=hostids":\[").*(?="\]\},"id)'`

curlDataUpd="{ "jsonrpc": "2.0", "method": "host.update", "params": { "hostid": "HOSTID", "templates": [ { "templateid": "13845", "templateid": "10001", "templateid": "10050" } ] },\"auth\":\"$authToken\",\"id\":1}"








