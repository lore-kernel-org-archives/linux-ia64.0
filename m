From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 10 Sep 2003 18:16:38 +0000
Subject: [PATCH] 2.4 IA64 config help update
Message-Id: <marc-linux-ia64-106321818220437@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This updates some IA64-specific config help text to match
what's in 2.5.

=== Documentation/Configure.help 1.192 vs edited ==--- 1.192/Documentation/Configure.help	Wed Sep  3 18:40:00 2003
+++ edited/Documentation/Configure.help	Wed Sep 10 14:13:05 2003
@@ -27000,11 +27000,13 @@
 # Choice: ia64type
 Itanium
 CONFIG_ITANIUM
-  Select your IA64 processor type.  The default is Intel Itanium.
+  Select your IA-64 processor type.  The default is Intel Itanium.
+  This choice is safe for all IA-64 systems, but may not perform
+  optimally on systems with, say, Itanium 2 or newer processors.
 
-McKinley
+Itanium 2
 CONFIG_MCKINLEY
-  Select this to configure for a McKinley processor.
+  Select this to configure for an Itanium 2 (McKinley) processor.
 
 # Choice: ia64system
 IA-64 system type
@@ -27060,6 +27062,14 @@
 CONFIG_IA64_MCA
   Say Y here to enable machine check support for IA-64.  If you're
   unsure, answer Y.
+
+Use PAL_HALT_LIGHT in idle loop
+CONFIG_IA64_PAL_IDLE
+  Say Y here to enable use of PAL_HALT_LIGHT in the cpu_idle loop.
+  This allows the CPU to enter a low power state when idle.  You
+  can enable CONFIG_IA64_PALINFO and check /proc/pal/cpu0/power_info
+  to see the power consumption and latency for this state.  If you're
+  unsure your firmware supports it, answer N.
 
 Disable IA-64 Virtual Hash Page Table
 CONFIG_DISABLE_VHPT

