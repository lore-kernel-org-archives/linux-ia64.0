From: Olaf Hering <olh@suse.de>
Date: Sun, 10 Jul 2005 19:35:11 +0000
Subject: [PATCH 3/82] remove linux/version.h include from arch/ia64
Message-Id: <20050710193511.3.HkjxyJ2330.2247.olh@nectarine.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20050710193508.0.PmFpst2252.2247.olh@nectarine.suse.de>  
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org


changing CONFIG_LOCALVERSION rebuilds too much, for no appearent reason.

Signed-off-by: Olaf Hering <olh@suse.de>

arch/ia64/kernel/perfmon.c  |    1 -
arch/ia64/sn/kernel/tiocx.c |    1 -
include/asm-ia64/sn/xp.h    |    1 -
3 files changed, 3 deletions(-)

Index: linux-2.6.13-rc2-mm1/arch/ia64/kernel/perfmon.c
=================================--- linux-2.6.13-rc2-mm1.orig/arch/ia64/kernel/perfmon.c
+++ linux-2.6.13-rc2-mm1/arch/ia64/kernel/perfmon.c
@@ -37,7 +37,6 @@
#include <linux/vfs.h>
#include <linux/pagemap.h>
#include <linux/mount.h>
-#include <linux/version.h>
#include <linux/bitops.h>
#include <linux/rcupdate.h>

Index: linux-2.6.13-rc2-mm1/arch/ia64/sn/kernel/tiocx.c
=================================--- linux-2.6.13-rc2-mm1.orig/arch/ia64/sn/kernel/tiocx.c
+++ linux-2.6.13-rc2-mm1/arch/ia64/sn/kernel/tiocx.c
@@ -8,7 +8,6 @@

#include <linux/module.h>
#include <linux/kernel.h>
-#include <linux/version.h>
#include <linux/slab.h>
#include <linux/spinlock.h>
#include <linux/proc_fs.h>
Index: linux-2.6.13-rc2-mm1/include/asm-ia64/sn/xp.h
=================================--- linux-2.6.13-rc2-mm1.orig/include/asm-ia64/sn/xp.h
+++ linux-2.6.13-rc2-mm1/include/asm-ia64/sn/xp.h
@@ -16,7 +16,6 @@
#define _ASM_IA64_SN_XP_H


-#include <linux/version.h>
#include <linux/cache.h>
#include <linux/hardirq.h>
#include <asm/sn/types.h>
