From: Matt_Domsch@Dell.com
Date: Tue, 11 Dec 2001 04:17:06 +0000
Subject: [Linux-ia64] new GPT and uuid patches
Message-Id: <marc-linux-ia64-105590698805679@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> In any case, I will put out a new ia64 patch this
> week because I'll be on vacation the week after.

David, I've got two patches for you which I believe are correct, but could
use some additional eyes just to make sure I didn't miss something.
http://domsch.com/linux/patches/ia64/linux-2.4.16-ia64-011128-gpt-20011210.p
atch
http://domsch.com/linux/patches/ia64/linux-2.4.16-ia64-011128-uuid-20011210.
patch

The GPT patch syncs fs/partitions/efi.[ch] up with my current GPT code.
Changes look big there because I fixed the function and struct names to be
more Linux-like.  It also deletes the CONFIG_DEVFS_GUID code per Martin
Wilck.  I've been hoping to get this into the stock kernel and out of the
IA64 port, but I needed a new crc32 library patch in first which has been
delayed until 2.4.18pre.  Since the ia64 patch already has an equivalent
implementation of crc32(), this is fine.  Once the larger crc32 patch makes
it into 2.4.18pre, we can drop the whole files lib/crc32.c,
include/linux/crc32.h, fs/partitions/efi.[ch] from the IA64 patch.

The uuid patch moves uuid_unparse() out of arch/ia64/kernel/efivars.c into
efi.c (and prototypes in include/asm-ia64/efi.h, now named
efi_guid_unparse()).  Currently, only efivars.c uses it, but the former
CONFIG_DEVFS_GUID code did too, and it was generally thought to be useful in
more places.  I withdraw my previous patch implementing uuid.[ch] as
libraries, letting efi_guid_t remain it's own unique thing.  It was hard
enough getting the crc32 library patch submitted, making other non-critical
library cleanups is more than I can handle ATM.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#1 US Linux Server provider with 24% (IDC Sept 2001)
#2 Worldwide Linux Server provider with 17% (IDC Sept 2001)
#3 Unix provider with 18% in the US (Dataquest)!

