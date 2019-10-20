#!/usr/bin/python2
from pyzabbix import ZabbixAPI

'''
DOCUMENTATION:
https://github.com/lukecyca/pyzabbix
https://github.com/adubkov/py-zabbix
https://pypi.org/project/py-zabbix/

examples:
https://github.com/lukecyca/pyzabbix/tree/master/examples

methods:
https://www.zabbix.com/documentation/3.0/manual/api

Notes on using pyzabbix:
session.method(params)
'''

# variables
server_ip = "192.168.56.11"
host_ip = "192.168.56.33"
server_url = "http://192.168.56.11:"

zabbix_user = 'Admin'
user_password = 'zabbix'

Templatename = "custom template111333"
Hostname = "tomcat111333"
GroupName = "CloudHosts011"

# functions
def create_group(session,gname):
    group = session.hostgroup.create(name=gname)
    return group['groupids'][0]

# TODO
def create_template(session,tname):
    None

def create_host(session,hname):
    None

# Connect to ZabbixAPI
zapi = ZabbixAPI(server_url)
zapi.session.verify = False # disable ssl
zapi.login(zabbix_user, user_password)
print("Connected to Zabbix API Version %s" % zapi.api_version())


# Output current hosts
print '*** SERVER HOSTS ***'
hosts = zapi.host.get(output=['name'])
for host in hosts:
    print host['name']


# Output current groups
print '*** HOST GROUPS ***'
groups = zapi.hostgroup.get(output=['itemid','name'])
for group in groups:
    print group['groupid'] + ": " + group['name']


# Create user-group
group_id = ""
groups = zapi.hostgroup.get(output=['itemid'],filter={"name":GroupName})
if not groups:
    group_id = create_group(zapi,GroupName)
else:
    group_id = groups[0]['groupid']

# create template
#template = zapi.template.create(output=['itemid','name'], host=[Templatename], groups={'groupid': group_id})
#for t in template: 
#    print t['itemid'] + ": " + t['name']
template_id = ""
try:
    templates = zapi.do_request('template.create',    
        {
            "host": Templatename,
            "groups": {
                "groupid": group_id
            },
        })
    for t in templates['result']['templateids']:
        template_id = t

except Exception as e:
    print e

# create host
hosts = zapi.do_request('host.create',
    {
        "host": Hostname,
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": host_ip,
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": group_id
            }
        ],
        "templates": [
            {
                "templateid": template_id
            },
            {
				"templateid": "10001"
			}
		
        ]
    })
