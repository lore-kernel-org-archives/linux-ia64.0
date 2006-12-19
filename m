From: akpm@osdl.org
Date: Tue, 19 Dec 2006 21:04:42 +0000
Subject: [patch 1/3] ia64: enable CONFIG_DEBUG_SPINLOCK_SLEEP
Message-Id: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

Some trivial bugs are coming from ia64 developers.  Try to help them.

Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 arch/ia64/configs/bigsur_defconfig    |    2 +-
 arch/ia64/configs/gensparse_defconfig |    2 +-
 arch/ia64/configs/sim_defconfig       |    2 +-
 arch/ia64/configs/sn2_defconfig       |    2 +-
 arch/ia64/configs/tiger_defconfig     |    4 ++--
 arch/ia64/configs/zx1_defconfig       |    2 +-
 arch/ia64/defconfig                   |    2 +-
 7 files changed, 8 insertions(+), 8 deletions(-)

diff -puN arch/ia64/configs/bigsur_defconfig~ia64-enable-config_debug_spinlock_sleep arch/ia64/configs/bigsur_defconfig
--- a/arch/ia64/configs/bigsur_defconfig~ia64-enable-config_debug_spinlock_sleep
+++ a/arch/ia64/configs/bigsur_defconfig
@@ -1305,7 +1305,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 CONFIG_DEBUG_PREEMPT=y
 CONFIG_DEBUG_MUTEXES=y
 # CONFIG_DEBUG_SPINLOCK is not set
-# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_DEBUG_FS is not set
diff -puN arch/ia64/configs/sim_defconfig~ia64-enable-config_debug_spinlock_sleep arch/ia64/configs/sim_defconfig
--- a/arch/ia64/configs/sim_defconfig~ia64-enable-config_debug_spinlock_sleep
+++ a/arch/ia64/configs/sim_defconfig
@@ -694,7 +694,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 CONFIG_DEBUG_PREEMPT=y
 CONFIG_DEBUG_MUTEXES=y
 # CONFIG_DEBUG_SPINLOCK is not set
-# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
 # CONFIG_DEBUG_FS is not set
diff -puN arch/ia64/configs/sn2_defconfig~ia64-enable-config_debug_spinlock_sleep arch/ia64/configs/sn2_defconfig
--- a/arch/ia64/configs/sn2_defconfig~ia64-enable-config_debug_spinlock_sleep
+++ a/arch/ia64/configs/sn2_defconfig
@@ -1284,7 +1284,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_MUTEXES is not set
 # CONFIG_DEBUG_RWSEMS is not set
-# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
 # CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
diff -puN arch/ia64/configs/tiger_defconfig~ia64-enable-config_debug_spinlock_sleep arch/ia64/configs/tiger_defconfig
--- a/arch/ia64/configs/tiger_defconfig~ia64-enable-config_debug_spinlock_sleep
+++ a/arch/ia64/configs/tiger_defconfig
@@ -1,4 +1,4 @@
-#
+;#
 # Automatically generated make config: don't edit
 # Linux kernel version: 2.6.16-rc5
 # Mon Feb 27 15:49:18 2006
@@ -1190,7 +1190,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_MUTEXES=y
 # CONFIG_DEBUG_SPINLOCK is not set
-# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_DEBUG_FS is not set
diff -puN arch/ia64/configs/zx1_defconfig~ia64-enable-config_debug_spinlock_sleep arch/ia64/configs/zx1_defconfig
--- a/arch/ia64/configs/zx1_defconfig~ia64-enable-config_debug_spinlock_sleep
+++ a/arch/ia64/configs/zx1_defconfig
@@ -1359,7 +1359,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_MUTEXES=y
 # CONFIG_DEBUG_SPINLOCK is not set
-# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_DEBUG_FS is not set
diff -puN arch/ia64/configs/gensparse_defconfig~ia64-enable-config_debug_spinlock_sleep arch/ia64/configs/gensparse_defconfig
--- a/arch/ia64/configs/gensparse_defconfig~ia64-enable-config_debug_spinlock_sleep
+++ a/arch/ia64/configs/gensparse_defconfig
@@ -1339,7 +1339,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_MUTEXES=y
 # CONFIG_DEBUG_SPINLOCK is not set
-# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_DEBUG_FS is not set
diff -puN arch/ia64/defconfig~ia64-enable-config_debug_spinlock_sleep arch/ia64/defconfig
--- a/arch/ia64/defconfig~ia64-enable-config_debug_spinlock_sleep
+++ a/arch/ia64/defconfig
@@ -1339,7 +1339,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_MUTEXES=y
 # CONFIG_DEBUG_SPINLOCK is not set
-# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_DEBUG_FS is not set
_
