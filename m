From: Matt_Domsch@Dell.com
Date: Mon, 28 Aug 2000 21:58:28 +0000
Subject: RE: [Linux-ia64] ia64 redhat 7 beta
Message-Id: <marc-linux-ia64-105590678205393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205392@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205392@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You need to enable support in the QLogic BIOS for addresses > 4GB.  That
will take care of it.

Thanks,
Matt Domsch
Dell Enterprise Systems Group
IA-64 Linux Lead Engineer

-----Original Message-----
From: Mike Sklar [mailto:sklarm@screwdecaf.cx]
Sent: Monday, August 28, 2000 4:46 PM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] ia64 redhat 7 beta



This morning (8/28) I picked up the 8/25 redhat ia64 iso off their site.

ftp://ftp.redhat.com/pub/redhat/ia64/iso/

When trying to boot of the cd I had made, I timed out on every SCSI
target. Just wondering if anyone else has seen this behavior? I tried
it on two of my newer BigSur systems, and both had the same issues.

scsi(0) : ABORT Command 0xe
scsi: aborting command due to timeout: pid 0, scsi 0, channel 1,
id 7, lun 0, inquery 00 00 00 ff 00.

Eventually I am able to boot off the cd and the install times out while
formatting my partitions (the alt-f4) console shows something like:

<4>scsi(0): ABORT Command=0xe00000000009ed40, handle=0x11
<4>SCSI host 0 abort (pid 0) timed out - resetting
<4>SCSI bus is being reset for host 0 channel 0.
<4>scsi(): Resetting Cmnd=0xe00000000009f940, Handle=0xe, flags=0x2
<6>scsi(0:0:0:0): Queueing device reset command.
<4>scsi : aborting command due to timeout : pid 0,scsi0, channel 0, id 0,
lun 0 Read (10) 00 00 0f b0 40 00 00 02 00


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


