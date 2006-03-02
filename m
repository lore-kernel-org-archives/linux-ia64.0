From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Mar 2006 22:02:32 +0000
Subject: PATCH[4/4] - Increase max node count on SN platforms
Message-Id: <20060302220232.GA17657@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Update configuration files with new CONFIG option.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 configs/gensparse_defconfig |    1 +
 configs/sn2_defconfig       |    1 +
 defconfig                   |    1 +
 3 files changed, 3 insertions(+)




Index: linux/arch/ia64/defconfig
=================================--- linux.orig/arch/ia64/defconfig	2006-03-01 16:07:24.000000000 -0600
+++ linux/arch/ia64/defconfig	2006-03-02 15:27:11.948214644 -0600
@@ -116,6 +116,7 @@ CONFIG_IOSAPIC=y
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
+CONFIG_IA64_NR_NODES%6
 CONFIG_HOTPLUG_CPU=y
 # CONFIG_SCHED_SMT is not set
 # CONFIG_PREEMPT is not set
Index: linux/arch/ia64/configs/gensparse_defconfig
=================================--- linux.orig/arch/ia64/configs/gensparse_defconfig	2006-03-01 16:07:24.000000000 -0600
+++ linux/arch/ia64/configs/gensparse_defconfig	2006-03-02 15:32:17.298135055 -0600
@@ -116,6 +116,7 @@ CONFIG_IOSAPIC=y
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
+CONFIG_IA64_NR_NODES%6
 CONFIG_HOTPLUG_CPU=y
 # CONFIG_SCHED_SMT is not set
 # CONFIG_PREEMPT is not set
Index: linux/arch/ia64/configs/sn2_defconfig
=================================--- linux.orig/arch/ia64/configs/sn2_defconfig	2006-03-01 16:07:24.000000000 -0600
+++ linux/arch/ia64/configs/sn2_defconfig	2006-03-02 15:32:21.071202353 -0600
@@ -116,6 +116,7 @@ CONFIG_IA64_SGI_SN_XP=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUS24
+CONFIG_IA64_NR_NODES%6
 # CONFIG_HOTPLUG_CPU is not set
 CONFIG_SCHED_SMT=y
 CONFIG_PREEMPT=y
