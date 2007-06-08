From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 08 Jun 2007 01:03:49 +0000
Subject: [IA64] Default to use the SLUB allocator
Message-Id: <Pine.LNX.4.64.0706071802500.14474@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Default all IA64 configurations in arch/ia64/configs to use SLUB.

SLUB has less overhead, is particularly faster on architectures with large
pagesizes such as IA64, has build in diagnostics that do not require a
kernel rebuilt and has a reporting system.

This also will enable the use of slab defragmentation by default once that is
merged upstream.

(Sounds awfully like too much marketing here. Hopefully there are no bugs
left...)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: slub/arch/ia64/configs/sn2_defconfig
=================================--- slub.orig/arch/ia64/configs/sn2_defconfig	2007-06-07 17:41:42.000000000 -0700
+++ slub/arch/ia64/configs/sn2_defconfig	2007-06-07 17:47:35.000000000 -0700
@@ -46,7 +46,7 @@ CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 CONFIG_VM_EVENT_COUNTERS=y
 CONFIG_RT_MUTEXES=y
 # CONFIG_TINY_SHMEM is not set
Index: slub/arch/ia64/configs/bigsur_defconfig
=================================--- slub.orig/arch/ia64/configs/bigsur_defconfig	2007-06-07 17:43:25.000000000 -0700
+++ slub/arch/ia64/configs/bigsur_defconfig	2007-06-07 17:43:32.000000000 -0700
@@ -42,7 +42,7 @@ CONFIG_CC_ALIGN_FUNCTIONS=0
 CONFIG_CC_ALIGN_LABELS=0
 CONFIG_CC_ALIGN_LOOPS=0
 CONFIG_CC_ALIGN_JUMPS=0
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
 # CONFIG_SLOB is not set
Index: slub/arch/ia64/configs/gensparse_defconfig
=================================--- slub.orig/arch/ia64/configs/gensparse_defconfig	2007-06-07 17:43:38.000000000 -0700
+++ slub/arch/ia64/configs/gensparse_defconfig	2007-06-07 17:43:46.000000000 -0700
@@ -43,7 +43,7 @@ CONFIG_CC_ALIGN_FUNCTIONS=0
 CONFIG_CC_ALIGN_LABELS=0
 CONFIG_CC_ALIGN_LOOPS=0
 CONFIG_CC_ALIGN_JUMPS=0
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
 # CONFIG_SLOB is not set
Index: slub/arch/ia64/configs/sim_defconfig
=================================--- slub.orig/arch/ia64/configs/sim_defconfig	2007-06-07 17:43:54.000000000 -0700
+++ slub/arch/ia64/configs/sim_defconfig	2007-06-07 17:43:59.000000000 -0700
@@ -43,7 +43,7 @@ CONFIG_CC_ALIGN_FUNCTIONS=0
 CONFIG_CC_ALIGN_LABELS=0
 CONFIG_CC_ALIGN_LOOPS=0
 CONFIG_CC_ALIGN_JUMPS=0
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
 # CONFIG_SLOB is not set
Index: slub/arch/ia64/configs/tiger_defconfig
=================================--- slub.orig/arch/ia64/configs/tiger_defconfig	2007-06-07 17:43:09.000000000 -0700
+++ slub/arch/ia64/configs/tiger_defconfig	2007-06-07 17:43:17.000000000 -0700
@@ -48,7 +48,7 @@ CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 CONFIG_VM_EVENT_COUNTERS=y
 CONFIG_RT_MUTEXES=y
 # CONFIG_TINY_SHMEM is not set
Index: slub/arch/ia64/configs/zx1_defconfig
=================================--- slub.orig/arch/ia64/configs/zx1_defconfig	2007-06-07 17:44:05.000000000 -0700
+++ slub/arch/ia64/configs/zx1_defconfig	2007-06-07 17:44:18.000000000 -0700
@@ -48,7 +48,7 @@ CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 CONFIG_VM_EVENT_COUNTERS=y
 CONFIG_RT_MUTEXES=y
 # CONFIG_TINY_SHMEM is not set
