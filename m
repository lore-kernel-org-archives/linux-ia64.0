From: Doug Beattie <dbb@sco.com>
Date: Tue, 29 Aug 2000 18:07:07 +0000
Subject: [Fwd: [Fwd: [Linux-ia64] ia64 redhat 7 beta]]
Message-Id: <marc-linux-ia64-105590678205407@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt and others:

I am seeing some similar behavior on a BigSur I have, but changing the
Qlogic BIOS to enable addresses >4GB just added to the problems.

1. Does anyone else have a problem getting into the Qlogic Fast!Util
on their IA64 system?
I have to place the card into a 32 bit system to access the bios and
make a change, then place it back into my BigSur to try it.

2. I see the timeouts when the kernel is probing for device
information as well as when trying to look for partitioning, etc. I
see this with a 2.4.0-test1 release from Caldera Systems. (I do not
see the problem with an internal test release we built withing SCO. It
handles the card just fine.) Any ideas?

3. With addressing >4GB turned off, probing for targets only finds one
device as it should at sda. With addressing >4GB enabled a device,
(the same drive), is detected on both channels 0 and 1 on each of the
0-15 targets. This probing yields devices sda through sdz and sdaa
through sdad being seen by the kernel. With the addressing >4GB
enabled after seeing all these bogus devices I get a Panic <NULL> due
to panic @0x890171. Looking at a back trace shows I'm in the qla1280
driver code calling a status routine from the isr function. I don't
get this with addressing >4GB disabled.

I believe I get the timeouts because the interrupts are not being seen
by the kernel properly.

I don't know why I can't get to the Qlogic bios with the altQ method
on an IA64 even though it says the key strokes have been detected.

Thanks for any help you may provide.

Doug
----------------------------------------------------------------------
> 
> Subject: RE: [Linux-ia64] ia64 redhat 7 beta
> Date: Mon, 28 Aug 2000 16:58:28 -0500
> From: Matt_Domsch@dell.com
> To: sklarm@screwdecaf.cx, linux-ia64@linuxia64.org
> 
> You need to enable support in the QLogic BIOS for addresses > 4GB.  That
> will take care of it.
> 
> Thanks,
> Matt Domsch
> Dell Enterprise Systems Group
> IA-64 Linux Lead Engineer
> 
> -----Original Message-----
> From: Mike Sklar [mailto:sklarm@screwdecaf.cx]
> Sent: Monday, August 28, 2000 4:46 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] ia64 redhat 7 beta
> 
> This morning (8/28) I picked up the 8/25 redhat ia64 iso off their site.
> 
> ftp://ftp.redhat.com/pub/redhat/ia64/iso/
> 
> When trying to boot of the cd I had made, I timed out on every SCSI
> target. Just wondering if anyone else has seen this behavior? I tried
> it on two of my newer BigSur systems, and both had the same issues.
> 
> scsi(0) : ABORT Command 0xe
> scsi: aborting command due to timeout: pid 0, scsi 0, channel 1,
> id 7, lun 0, inquery 00 00 00 ff 00.
> 
> Eventually I am able to boot off the cd and the install times out while
> formatting my partitions (the alt-f4) console shows something like:
> 
> <4>scsi(0): ABORT Command=0xe00000000009ed40, handle=0x11
> <4>SCSI host 0 abort (pid 0) timed out - resetting
> <4>SCSI bus is being reset for host 0 channel 0.
> <4>scsi(): Resetting Cmnd=0xe00000000009f940, Handle=0xe, flags=0x2
> <6>scsi(0:0:0:0): Queueing device reset command.
> <4>scsi : aborting command due to timeout : pid 0,scsi0, channel 0, id 0,
> lun 0 Read (10) 00 00 0f b0 40 00 00 02 00
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Douglas B. Beattie
------------------
Linux Test Architect - SCO, Inc.
dbb@sco.com

