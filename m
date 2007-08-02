From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 02 Aug 2007 20:15:16 +0000
Subject: Subject: [PATCH] Update arch/ia64/configs/*
Message-Id: <Pine.LNX.4.64.0708021314420.9480@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From 51cb6e675166e7577748f3c7174dd1fc9a414276 Mon Sep 17 00:00:00 2001
From: Christoph Lameter <clameter@schroedinger.engr.sgi.com>
Date: Sat, 28 Jul 2007 19:21:07 -0700
Subject: [PATCH] Update arch/ia64/configs/*

The slab allocator was changed in 2.6.23 to default to SLUB. However,
the config files in arch/ia64/configs still use SLAB. Switch them to SLUB.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 arch/ia64/configs/bigsur_defconfig    |    2 +-
 arch/ia64/configs/gensparse_defconfig |    2 +-
 arch/ia64/configs/sim_defconfig       |    2 +-
 arch/ia64/configs/sn2_defconfig       |    2 +-
 arch/ia64/configs/tiger_defconfig     |    2 +-
 arch/ia64/configs/zx1_defconfig       |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index 9eb48c0..6dd8655 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -42,7 +42,7 @@ CONFIG_CC_ALIGN_FUNCTIONS=0
 CONFIG_CC_ALIGN_LABELS=0
 CONFIG_CC_ALIGN_LOOPS=0
 CONFIG_CC_ALIGN_JUMPS=0
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
 # CONFIG_SLOB is not set
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index 3a9ed95..e86fbd3 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -43,7 +43,7 @@ CONFIG_CC_ALIGN_FUNCTIONS=0
 CONFIG_CC_ALIGN_LABELS=0
 CONFIG_CC_ALIGN_LOOPS=0
 CONFIG_CC_ALIGN_JUMPS=0
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
 # CONFIG_SLOB is not set
diff --git a/arch/ia64/configs/sim_defconfig b/arch/ia64/configs/sim_defconfig
index c420d9f..546a772 100644
--- a/arch/ia64/configs/sim_defconfig
+++ b/arch/ia64/configs/sim_defconfig
@@ -43,7 +43,7 @@ CONFIG_CC_ALIGN_FUNCTIONS=0
 CONFIG_CC_ALIGN_LABELS=0
 CONFIG_CC_ALIGN_LOOPS=0
 CONFIG_CC_ALIGN_JUMPS=0
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
 # CONFIG_SLOB is not set
diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index 4c9ffc4..9aecfce 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -46,7 +46,7 @@ CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 CONFIG_VM_EVENT_COUNTERS=y
 CONFIG_RT_MUTEXES=y
 # CONFIG_TINY_SHMEM is not set
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index 3dbb398..797acf9 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -53,7 +53,7 @@ CONFIG_TIMERFD=y
 CONFIG_EVENTFD=y
 CONFIG_SHMEM=y
 CONFIG_VM_EVENT_COUNTERS=y
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 # CONFIG_SLUB is not set
 # CONFIG_SLOB is not set
 CONFIG_RT_MUTEXES=y
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index 4a060fc..0a06b13 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -48,7 +48,7 @@ CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
-CONFIG_SLAB=y
+CONFIG_SLUB=y
 CONFIG_VM_EVENT_COUNTERS=y
 CONFIG_RT_MUTEXES=y
 # CONFIG_TINY_SHMEM is not set
-- 
1.5.2.4

