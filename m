From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Sun, 30 Jul 2000 17:27:54 +0000
Subject: RE: [Linux-ia64] kernel update [relative to 2.4.0-test4]
Message-Id: <marc-linux-ia64-105590678205244@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205242@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205242@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Here is the latest kernel update.  Before I go on, two major caveats:
> 
>  BIG CAVEAT
> 	To run this kernel on a system with a SCSI controller that
> 	uses the PCI DMA interface (e.g, adaptec), you'll have to
> 	specific boot option mem=4G to force the kernel to ignore
> 	memory above 4GB.  This is a temporary issue and will be fixed
> 	in the next version.
> 
>  BIG CAVEAT
> 	This kernel will work fine with the qla1280 SCSI driver, even
> 	if there is memory above 4GB.  However, you must make sure
> 	that "64 bit addressing" is enabled in the Qlogic BIOS setup
> 	(press "Alt-Q" during system initialization to get into the
> 	SCSI controller configuration menu).  If your system is unable
> 	to mount the root filesystem, chances are you forgot to
> 	do this.
> 
> OK, having said that, here are the major goodies:
> 
>  - Support for software I/O TLB is in, thanks to Goutham and Asit
>    (Intel).  This support allows to DMA from 32-bit PCI devices to any
>    place in the physical memory.  However, the transfer size is
>    currently limited to one page and this is the reason SCSI drivers
>    such as the adaptec drivers do not work yet

All the SCSI devices will work as long as it is a 64-bit PCI SCSI device and
the dma_mask is set to 0xFFFFFFFFFFFFFFFF. We have a prototype working that
supports I/O TLB mapping of more than a page size and will get the patch out
as soon as possible.

Thanks,
Asit




