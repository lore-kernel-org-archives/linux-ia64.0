From: Alex Chiang <achiang@hp.com>
Date: Thu, 05 Mar 2009 23:55:06 +0000
Subject: flatmem config broken?
Message-Id: <20090305235506.GG14408@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone tried building wtih flatmem memory model lately?

I tried starting with the latest defconfig, changed the memory
model to flatmem, and ended up with a whole bunch of build
errors.

mm/built-in.o(.text+0x59d00): In function `hugetlb_cow':
: undefined reference to `max_mapnr'
mm/built-in.o(.text+0x59d10): In function `hugetlb_cow':
: undefined reference to `mem_map'

&c.


achiang@bob:linux-2.6$ git grep CONFIG_FLATMEM_MANUAL
arch/ia64/configs/bigsur_defconfig:CONFIG_FLATMEM_MANUAL=y
arch/ia64/configs/generic_defconfig:# CONFIG_FLATMEM_MANUAL is not set
arch/ia64/configs/gensparse_defconfig:# CONFIG_FLATMEM_MANUAL is not set
arch/ia64/configs/sim_defconfig:CONFIG_FLATMEM_MANUAL=y
arch/ia64/configs/tiger_defconfig:CONFIG_FLATMEM_MANUAL=y
arch/ia64/configs/xen_domu_defconfig:CONFIG_FLATMEM_MANUAL=y
arch/ia64/configs/zx1_defconfig:CONFIG_FLATMEM_MANUAL=y

Looks like we still think that flatmem should work on certain
ia64 platforms...

Thanks.

/ac

