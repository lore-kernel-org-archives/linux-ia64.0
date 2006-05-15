From: Jes Sorensen <jes@sgi.com>
Date: Mon, 15 May 2006 09:07:54 +0000
Subject: [patch] sn2 defconfig repost
Message-Id: <yq0zmhjpset.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

I think this one slipped through the cracks.

Cheers,
Jes

Set node shift to 10 on SN2 and disable mutex debugging.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/configs/sn2_defconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/arch/ia64/configs/sn2_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig
+++ linux-2.6/arch/ia64/configs/sn2_defconfig
@@ -134,7 +134,7 @@
 CONFIG_ARCH_SPARSEMEM_ENABLE=y
 CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
 CONFIG_NUMA=y
-CONFIG_NODES_SHIFT=8
+CONFIG_NODES_SHIFT
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_HOLES_IN_ZONE=y
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
@@ -1159,7 +1159,7 @@
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_PREEMPT=y
-CONFIG_DEBUG_MUTEXES=y
+# CONFIG_DEBUG_MUTEXES is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
 # CONFIG_DEBUG_KOBJECT is not set
