From: Bill Nottingham <notting@redhat.com>
Date: Thu, 07 Dec 2000 14:25:23 +0000
Subject: [Linux-ia64] Re: fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205809@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Einar Saltnes (eisa@scali.no) said: 
> Hi,
> I'm trying to mount the LS120 drive on BigSur, but fail getting
> the following message:
> 
> [root@scali9-12 linux-2.4.0-test10]# mount /mnt/floppy
> /dev/hdb1: Invalid argument
> mount: /dev/hdb1 has wrong major or minor number
> 
> Same result with floppy and LS120 floppy.

If you don't have a partitioned floppy, just mount the raw
device, i.e.:

mount /dev/hdb -t <filesystem type> /mnt/floppy

Bill

