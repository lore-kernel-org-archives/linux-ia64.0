From: "vivek" <svivek@pspl.co.in>
Date: Wed, 23 Aug 2000 11:22:21 +0000
Subject: [Linux-ia64] problem installing linux ia-64 over NFS
Message-Id: <marc-linux-ia64-105590678205385@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,
    i am installinf linux ia-64 on my itanium m/c over NFS. The insatallable
of linux ia64 are downloaded from the ftp site of redhat ia64 linux. When i
started the installtion process , it booted nicely from LS-120 floopy,i t
probed me for network config of host and nfs server, then it ask me for the
path of directory where installables are kept. when i gave it, it prompted
the error that 'the directory does not contain proper installation tree';

Does it need a perticular directory structure, if yes what it is.

I Directory i download from FTP site was /pub/redhat/ia64 of the ftp m/c.

i down loaded it on my m/c in some directory say "x",
then i mounted that
so i have /mnt/x
which has three directories : -ia64
					   |---redhat
						|--- base
						|---instimages
						|--RPMS
					   |---images
					-iso
					-SRPMS

What path should i give while nfs installations.
Desperately waiting for reply
vivek
=================
Vivek Shende
Member Of Tech. Staff at
Persistent Sys Pvt Ltd,
Pune, India 411016
ph. 5676700 ext 285
email : svivek@pspl.co.in
url : http://www.pspl.co.in


