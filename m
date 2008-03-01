From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 01 Mar 2008 07:51:28 +0000
Subject: [PATCH][2.6.25-rc2-mm1] ia64: remove unnecessary nfs includes from sys_ia32.c
Message-Id: <20080301164035.528F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "J. Bruce Fields" <bfields@citi.umich.edu>, linux-ia64@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi

if compile 2.6.25-rc2-mm1 on ia64, output many warnings.

----------------------------------------------------------------
% LANG=C make arch/ia64/ia32/sys_ia32.o
<-mm1% LANG=C make arch/ia64/ia32/sys_ia32.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CC      arch/ia64/ia32/sys_ia32.o
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:297:1: warning: "elf_check_arch" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:19:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:302:1: warning: "ELF_CLASS" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:24:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:304:1: warning: "ELF_ARCH" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:26:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:318:1: warning: "ELF_EXEC_PAGESIZE" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:34:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:327:1: warning: "ELF_ET_DYN_BASE" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:43:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:330:1: warning: "ELF_PLAT_INIT" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:140:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:342:1: warning: "SET_PERSONALITY" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/device.h:21,
                 from include/linux/backing-dev.h:15,
                 from include/linux/nfs_fs_sb.h:5,
                 from include/linux/nfs_fs.h:50,
                 from arch/ia64/ia32/sys_ia32.c:35:
include/asm/elf.h:180:1: warning: this is the location of the previous definition
------------------------------------------------------------------------

IA64 support 2 ELF format (IA64 binary and IA32 binary),
thus if 2 elf related header included, cause many warning or error.

about 2 week ago, J. Bruce Fields proposed this problem fixed patch.
(http://marc.info/?l=linux-ia64&m0329313305695&w=2)

but unfortunately, it can't applied -mm tree.
I rebase against 2.6.25-rc2-mm1.



Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 arch/ia64/ia32/sys_ia32.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

Index: b/arch/ia64/ia32/sys_ia32.c
=================================--- a/arch/ia64/ia32/sys_ia32.c 2008-02-18 17:13:15.000000000 +0900
+++ b/arch/ia64/ia32/sys_ia32.c 2008-03-01 16:48:36.000000000 +0900
@@ -32,13 +32,8 @@
 #include <linux/shm.h>
 #include <linux/slab.h>
 #include <linux/uio.h>
-#include <linux/nfs_fs.h>
+#include <linux/socket.h>
 #include <linux/quota.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr.h>
-#include <linux/nfsd/syscall.h>
 #include <linux/poll.h>
 #include <linux/eventpoll.h>
 #include <linux/personality.h>

