From: Matt_Domsch@Dell.com
Date: Wed, 14 Aug 2002 19:42:45 +0000
Subject: RE: [Linux-ia64] move asm-ia64/efi.h to linux/efi.h ?
Message-Id: <marc-linux-ia64-105590701905939@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905936@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905936@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Matt> David, any further thoughts on moving include/asm-ia64/efi.h
>   Matt> to linux/efi.h?
> 
> Oh, I'm obviously totally in favor of that, too.

David, please download and apply
http://domsch.com/linux/patches/ia64/linux-2.5-efihmove.cset
a BK patch against Linus' current BK tree, which also applies cleanly
against your 2.5.30 test patch posted two days ago.  This moves all
instances of #include <asm{"",-ia64}/efi.h> to <linux/efi.h>.

ChangeSet@1.504, 2002-08-13 22:24:31-05:00, Matt_Domsch@dell.com
  Move include/asm-ia64/efi.h to include/linux/efi.h
  This is required now that non-ia64 architectures are using EFI code,
  particularly the EFI GUID Partition Table (GPT) scheme for large disks.


 b/arch/ia64/hp/common/sba_iommu.c |    2 
 b/arch/ia64/hp/zx1/hpzx1_misc.c   |    2 
 b/arch/ia64/kernel/acpi.c         |    2 
 b/arch/ia64/kernel/efi.c          |    2 
 b/arch/ia64/kernel/efivars.c      |    2 
 b/arch/ia64/kernel/fw-emu.c       |    2 
 b/arch/ia64/kernel/palinfo.c      |    2 
 b/arch/ia64/kernel/process.c      |    2 
 b/arch/ia64/kernel/setup.c        |    2 
 b/arch/ia64/kernel/smp.c          |    2 
 b/arch/ia64/kernel/smpboot.c      |    2 
 b/arch/ia64/kernel/time.c         |    2 
 b/arch/ia64/mm/init.c             |    2 
 b/arch/ia64/sn/fakeprom/fpmem.c   |    2 
 b/arch/ia64/sn/fakeprom/fw-emu.c  |    2 
 b/arch/ia64/sn/io/efi-rtc.c       |    2 
 b/arch/ia64/sn/kernel/llsc4.c     |    2 
 b/drivers/acpi/osl.c              |    2 
 b/drivers/char/efirtc.c           |    2 
 b/fs/partitions/efi.h             |    6 
 b/include/asm-ia64/sal.h          |    2 
 b/include/linux/efi.h             |  284
++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/efi.h            |  284
--------------------------------------
 23 files changed, 305 insertions, 309 deletions


I was able to make a default ia64 config compile (after removing the video
stuff from .config), and the patch is very straightforward.  Please apply,
and forward to Linus as part of your 2.5.x merge.  I'll post a similar patch
against 2.4.x current BK tree soon as I have a moment to make it.

Thanks,
Matt


--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)


