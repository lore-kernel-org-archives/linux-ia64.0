From: Einar Saltnes <eisa@scali.no>
Date: Thu, 07 Dec 2000 14:03:02 +0000
Subject: [Linux-ia64] fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205808@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I'm trying to mount the LS120 drive on BigSur, but fail getting
the following message:

[root@scali9-12 linux-2.4.0-test10]# mount /mnt/floppy
/dev/hdb1: Invalid argument
mount: /dev/hdb1 has wrong major or minor number

Same result with floppy and LS120 floppy.

The /etc/fstab entry looks like this:
/dev/hdb1  /mnt/floppy  auto  noauto,owner  0 0

I'm running with ReHat developer distribution of August 25th with a
test10 kernel.

[root@scali9-12 linux-2.4.0-test10]# cat /etc/issue
Red Hat Linux release 6.96.1 (Zoot)
Kernel 2.4.0-t10.1kdbSMPB on a 2-processor ia64

Kernel config
- Block devices | Normal PC floppy disk support --> disabled
- ATA/IDE/...support | IDE, ATA and ATAPI Block dev | Include IDE/ATAPI
FLOPPY support --> enabled

What am I missing?

Thanks in advance,
Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

