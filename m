From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 24 May 2004 23:13:36 +0000
Subject: [PATCH] fix hotplug config placement
Message-Id: <200405241713.36245.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

HOTPLUG_CPU depends on SMP, so why not put it under SMP?

=== arch/ia64/Kconfig 1.73 vs edited ==--- 1.73/arch/ia64/Kconfig	2004-05-14 20:00:12 -06:00
+++ edited/arch/ia64/Kconfig	2004-05-24 17:05:32 -06:00
@@ -78,15 +78,6 @@
 
 endchoice
 
-config HOTPLUG_CPU
-    bool "Support for hot-pluggable CPUs (EXPERIMENTAL)"
-    depends on SMP && HOTPLUG && EXPERIMENTAL
-	default n
-    ---help---
-      Say Y here to experiment with turning CPUs off and on.  CPUs
-      can be controlled through /sys/devices/system/cpu/cpu#.
-      Say N if you want to disable cpu hotplug.
-
 choice
 	prompt "Processor type"
 	default ITANIUM
@@ -252,6 +243,15 @@
 	  only use 2 CPUs on a >2 CPU system.  Setting this to a value larger
 	  than 64 will cause the use of a CPU mask array, causing a small
 	  performance hit.
+
+config HOTPLUG_CPU
+    bool "Support for hot-pluggable CPUs (EXPERIMENTAL)"
+    depends on SMP && HOTPLUG && EXPERIMENTAL
+	default n
+    ---help---
+      Say Y here to experiment with turning CPUs off and on.  CPUs
+      can be controlled through /sys/devices/system/cpu/cpu#.
+      Say N if you want to disable CPU hotplug.
 
 config PREEMPT
 	bool "Preemptible Kernel"
