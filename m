From: Jean-Philippe BATTU <jean-philippe.battu@bull.net>
Date: Tue, 08 Oct 2002 07:57:52 +0000
Subject: [Linux-ia64] Again : Pb to write a tape ...
Message-Id: <marc-linux-ia64-105590701906088@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all

Sorry to disturb you again, but I continued to try to write on
my exabyte 8505 XL on ia64 , redhat 7.2
I found that large tar and large dump hang, but a direct
operation seems to work fine (cat /largefile >/dev/st0), and
tar and dump work fine if the destination is a file rather the
device tape file.
I examine mt and stinit, I was in 0.6 and I installed the 0.7
version after downloading it and compiling it. The problem
is still the same. When I use stinit to validate the drive, it seems
ok, but the next mt command will delete the previous initialisation.

Here is a sample copy of my command :

[root@ root]# date ; stinit
Tue Oct  8 08:49:09 CEST 2002
Initialized 1 tape devices.


[root@ root]# date ; mt -f /dev/st0 status
Tue Oct  8 08:49:21 CEST 2002
SCSI 2 tape drive:
File number=0, block number=0, partition=0.
Tape block size 512 bytes. Density code 0x8c (EXB-8505 compressed).
Soft error count since last status=0
General status bits on (41010000):
 BOT ONLINE IM_REP_EN

ok !

[root@ root]# date ; mt -f /dev/st0 status
Tue Oct  8 08:49:26 CEST 2002
SCSI 2 tape drive:
File number=0, block number=0, partition=0.
Tape block size 512 bytes. Density code 0x0 (default).
Soft error count since last status=0
General status bits on (41010000):
 BOT ONLINE IM_REP_EN

why the density code has been deleted ?

[root@ root]# mt -v
mt-st v. 0.7
[root@ root]#

Perhaps you will have an advice !
Any suggestions would be greatly appreciated

Cheers !

--

---------------------------------------------------------------------
Jean-Philippe BATTU            Phone   : (33) 04 76 29 73 43
Localisation: B1/403              Fax     : (33) 04 76 29 75 18
Mail : jean-philippe.battu@bull.net

Bull, 01 Rue de Provence
B.P. 208
38432 Echirolles FRANCE
---------------------------------------------------------------------



