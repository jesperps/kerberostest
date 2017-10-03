# Kerberos environment
Repo for getting infrastructure up and running for Kerberos

## Get started
### Simple way (if you are lucky)
- Just clone this repo `git clone <link to here>`
### The slightly harder way (if your git remote provider doesn't use proper certificates)
To workaround certificate issues you can disable ssl verfication in git. And you are probably only wanting to do this on this repo (otherwise you could have disabled it globally with `git config http.sslVerify "false"` and then do the above)
- Create a directory where you want this repo
    - `mkdir kerberos_client_server_setup`
- Go to the directory and initialize a git repo there
    - `cd kerberos_client_server_setup` 
    - `git init`
- Remove ssl verification (for this repo only)
    - `git config --local http.sslVerify "false"`
- Add a remote
    - `git remote add origin <link to here>`
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

### Environment
Theres is an (environments file)[./.env] where you can add nice stuff to customize you setup. The variables in this file are used while building images for the services defined in the (_docker-compose.yml_ file)[./docker-compose.yml] and when running the services. It looks like this:
```
$ cat .env
REALM=MYDOMAIN.COM
PROXY=
PW=password
$
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
- Login to a client-container:
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

## SSH and kerberos authentication

### Verify ssh with kerberos authentication
A testuser is added to the setup at startup of the containers. You can login to the _centosclient_ by `docker-compose exec centosclient /bin/bash`. And then create a kerberos ticket and ssh to the _sshserver_, like this:
```
[root@centosclient /]# kinit testuser
Password for testuser@MYDOMAIN.COM:
[root@centosclient /]# ssh testuser@sshserver.mydomain.com
The authenticity of host 'sshserver.mydomain.com (172.20.0.5)' can't be established.
ECDSA key fingerprint is SHA256:xTE0vHBOV/0BUm8/tPwgznyG0IXITlwP/c9fMGjLBDs.
ECDSA key fingerprint is MD5:56:ad:af:ae:90:c4:91:8b:fb:ab:ce:5b:32:27:36:c8.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'sshserver.mydomain.com,172.20.0.5' (ECDSA) to the list of known hosts.
[testuser@sshserver ~]$
```

### Enable kerberos authentication over ssh to more services
The server you want to login to also needs to be a kerberos klient. A valid `krb5.config` (using the _kerberosserver_ config will do nicely) _GSSAPIAuthentication_ needs to be enabled in the ssh config. Also thev server you want to login to needs to exist in the kerberos database and you need a keytab on the server in question.

#### Adding a server to the kerberos db and creating a keytab file
Before adding to the (_docker-compose.yml_ file)[./docker-compose.yml#L37-L42] you can test it out like this:
- Run `sudo docker-compose exec sshserver kadmin -q "addprinc -randkey host/<the server you want to login to>.mydomain.com"`
- And `sudo docker-compose exec sshserver kadmin -q "ktadd -k /etc/krb5.keytab host/<the server you want to login to>.mydomain.com"`

#### Adding users
The user you are going to use also needs to exist in the kerberos db and on the server you want to login to.
- Create one with `useradd <the user you untend to use>`
- Here's an example using the _sshserver_ and the _testuser_:
```
sudo docker-compose exec sshserver testuser
```

- For verification:
```
sudo docker-compose exec sshserver id -a testuser
uid=1000(testuser) gid=1000(testuser) groups=1000(testuser)
```

- And to kerberos:
```
sudo docker-compose exec kerberosserver kadmin.local -q "addprinc testuser"
```

- Verify that a user exists in kerberos:
```
sudo docker-compose exec kerberosserver kadmin.local -q "listprincs"
```

#### The _GSSAPIAuthentication_ stuff

- Make sure _GSSAPIAuthentication_ is enabled in `/etc/ssh/sshd_config` (on the server you want to login to)
```
GSSAPIAuthentication yes
```
- Also make sure it is enabled in `/etc/ssh/ssh_config` (on the client you are loging in from)
```
Host *
	GSSAPIAuthentication yes
```
- Check that you have a valid ticket (create a new with `kinit` if you don't)
```
sudo docker-compose exec centosclient klist -l

Principal name                 Cache name
--------------                 ----------
testuser@MYDOMAIN.COM          FILE:/tmp/krb5cc_0
pinky:kerberostest mrpink$
```
