# Kerberos environment
Repo for getting infrastructure up and running for Kerberos

## Get started
### Prepare a git repo
At the moment the certificate to https://git.ica.ia-hc.net can't be verified. To workaround that you can disable ssl verfication in git.
- Create a directory where you want this repo
    - `mkdir kerberos_client_server_setup`
- Go to the directory and initialize a git repo there
    - `cd kerberos_client_server_setup` 
    - `git init`
- Remove ssl verification (for this repo only)
    - `git config --local http.sslVerify "false"`
- Add a remote
    - `git remote add origin https://git.ica.ia-hc.net/Platform_services_team/kerberos_client_server_setup.git`
- Get all changes from the remote
    - `git pull`
    
### Nice colors to git 
If you like nice colors when working with git add the following to your `~/.gitconfig`
```
[color]
  diff = auto
  status = auto
  branch = auto
  interactive = auto
  ui = true
  pager = true
```
    
### Start it up
When started, local docker images will be created, this can take sometime (minutes, depending on network speed). 
- Start the dockerized setup
    - `sudo docker-compose up -d`
The process is quite verbose but will en with something like this:
```
...
Complete!
ssh-keygen: generating new host keys: RSA1 RSA DSA ECDSA ED25519
 ---> e6421e129e00
Removing intermediate container fe839661566e
Successfully built e6421e129e00
Successfully tagged kerberossetup_sshserver:latest
WARNING: Image for service sshserver was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Creating dnsserver ...
Creating mitserver ...
Creating kerberosserver ...
Creating sshserver ...
Creating centosclient ...
Creating kerberosclient ...
Creating dnsserver
Creating sshserver
Creating centosclient
Creating mitserver
Creating kerberosserver
Creating kerberosclient ... done
```
- You can verify that everything is up and running by runnig `sudo docker-compose ps`. Everything should have state `UP`, like this:
```
     Name                   Command               State          Ports
------------------------------------------------------------------------------
centosclient     bash -c while true; do dat ...   Up
dnsserver        bash -c /usr/sbin/named -u ...   Up      0.0.0.0:53->53/tcp
kerberosclient   bash -c while true; do dat ...   Up
kerberosserver   bash -c /etc/init.d/heimda ...   Up
mitserver        bash -c while true; do dat ...   Up
sshserver        /usr/sbin/sshd -D                Up      0.0.0.0:2222->22/tcp
```

## Verify kerberos
- Log in to a client-container:
    - `sudo docker-compose exec centosclient /bin/bash`
- Then run `kinit testuser` and use `password` as _password_ This will create a kerberos ticket
    - If no output is shown everything is great :)
- You can also verfy that you have a kerberos ticket with the `kinit` command, like this:

```
[root@centosclient /]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: testuser@MYDOMAIN.COM

Valid starting     Expires            Service principal
09/25/17 14:48:16  09/26/17 14:48:16  krbtgt/MYDOMAIN.COM@MYDOMAIN.COM
[root@centosclient /]#
```
    