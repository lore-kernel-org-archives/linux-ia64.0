From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 24 Sep 2004 16:01:21 +0000
Subject: [PATCH] sn2: disable cpu hotplug in sn2_defconfig
Message-Id: <200409241201.21764.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_RTEVBcnKbRX7FD3"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_RTEVBcnKbRX7FD3
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Looks like there are some bugs that won't be fixed before 2.6.9 in the 
scheduling domain code wrt HOTPLUG_CPU, so I'm disabling it in sn2_defconfig 
(we don't support CPU hotplug just yet anyway).

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_RTEVBcnKbRX7FD3
Content-Type: text/x-diff;
  charset="us-ascii";
  name="sn2-defconfig-disable-cpu-hotplug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-disable-cpu-hotplug.patch"

===== arch/ia64/configs/sn2_defconfig 1.13 vs edited =====
--- 1.13/arch/ia64/configs/sn2_defconfig	2004-09-21 12:45:15 -07:00
+++ edited/arch/ia64/configs/sn2_defconfig	2004-09-24 08:59:10 -07:00
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
 # Linux kernel version: 2.6.9-rc2
-# Fri Sep 17 13:58:32 2004
+# Fri Sep 24 08:59:00 2004
 #
 
 #
@@ -79,7 +79,7 @@
 CONFIG_FORCE_MAX_ZONEORDER=18
 CONFIG_SMP=y
 CONFIG_NR_CPUS=512
-CONFIG_HOTPLUG_CPU=y
+# CONFIG_HOTPLUG_CPU is not set
 CONFIG_PREEMPT=y
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y

--Boundary-00=_RTEVBcnKbRX7FD3--
