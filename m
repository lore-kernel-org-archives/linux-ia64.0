From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 27 Mar 2013 00:55:55 +0000
Subject: drivers/acpi/bgrt.c:undefined reference to `bgrt_tab' (defined in arch/x86/platform/efi/efi-bgrt.c)
Message-Id: <20130327005555.GA14974@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,

The error is bisected down to below commit, however I don't see
obvious correlations.

The problem is, drivers/acpi/bgrt.c references bgrt_tab etc. variables
defined in arch/x86/platform/efi/efi-bgrt.c which is obviously not
available in ia64.

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux master
head:   c4052ba9dad9cc86cb3a1f0f8cb032514fa414be
commit: 18a44a7ff1075ce5157ac07cde573aca6b5e9973 Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
date:   4 weeks ago
config: make ARCH=ia64 allmodconfig

All error/warnings:

   drivers/built-in.o: In function `show_yoffset':
>> bgrt.c:(.text+0xe5a71): undefined reference to `bgrt_tab'
>> bgrt.c:(.text+0xe5a91): undefined reference to `bgrt_tab'
   drivers/built-in.o: In function `show_xoffset':
>> bgrt.c:(.text+0xe5b51): undefined reference to `bgrt_tab'
>> bgrt.c:(.text+0xe5b71): undefined reference to `bgrt_tab'
   drivers/built-in.o: In function `show_type':
>> bgrt.c:(.text+0xe5c31): undefined reference to `bgrt_tab'
   drivers/built-in.o:bgrt.c:(.text+0xe5c51): more undefined references to `bgrt_tab' follow
   drivers/built-in.o: In function `bgrt_init':
   bgrt.c:(.init.text+0x8931): undefined reference to `bgrt_image'
   bgrt.c:(.init.text+0x8932): undefined reference to `bgrt_image_size'
   bgrt.c:(.init.text+0x8950): undefined reference to `bgrt_image'
   bgrt.c:(.init.text+0x8960): undefined reference to `bgrt_image_size'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
