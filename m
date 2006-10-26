From: Russ Anderson <rja@sgi.com>
Date: Thu, 26 Oct 2006 21:00:28 +0000
Subject: [patch] Update processor_info features
Message-Id: <200610262100.k9QL0Sf821995144@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Update processor_info features

Add the printing of additional processor features to proc_features.

Based on Rev 2.2 of Volume 2 of "Intel Itanium Architecture Software
Developer's Manual" (January 2006) fields (pages 2:430-2:432).
This patch gets the features back in sync with the spec.


Sample output before:
--------------------------------------------------------------
cobra:~ # cat /proc/pal/cpu0/processor_info
XIP,XPSR,XFS implemented                 : On NoCtrl
XR1-XR3 implemented                      : On NoCtrl
Disable dynamic predicate prediction     : NotImpl
Disable processor physical number        : NotImpl
Disable dynamic data cache prefetch      : NotImpl
Disable dynamic inst cache prefetch      : NotImpl
Disable dynamic branch prediction        : NotImpl
Disable BINIT on processor time-out      : On Ctrl
Disable dynamic power management (DPM)   : NotImpl
Disable coherency                        : NotImpl
Disable cache                            : NotImpl
Enable CMCI promotion                    : Off Ctrl
Enable MCA to BINIT promotion            : Off Ctrl
Enable MCA promotion                     : NotImpl
Enable BERR promotion                    : NotImpl
cobra:~ #
--------------------------------------------------------------

Sample output after:
--------------------------------------------------------------
cobra:~ # cat /proc/pal/cpu0/processor_info
Unimplemented instruction address fault  : NotImpl
INIT, PMI, and LINT pins                 : NotImpl
Simple unimplimented instr addresses     : On NoCtrl
Variable P-state performance             : NotImpl
Virtual machine features implemeted      : On NoCtrl
XIP,XPSR,XFS implemented                 : On NoCtrl
XR1-XR3 implemented                      : On NoCtrl
Disable dynamic predicate prediction     : NotImpl
Disable processor physical number        : NotImpl
Disable dynamic data cache prefetch      : NotImpl
Disable dynamic inst cache prefetch      : NotImpl
Disable dynamic branch prediction        : NotImpl
Disable P-states                         : Off Ctrl
Enable MCA on Data Poisoning             : Off Ctrl
Enable vmsw instruction                  : On Ctrl
Enable extern environmental notification : NotImpl
Disable BINIT on processor time-out      : On Ctrl
Disable dynamic power management (DPM)   : NotImpl
Disable coherency                        : NotImpl
Disable cache                            : NotImpl
Enable CMCI promotion                    : Off Ctrl
Enable MCA to BINIT promotion            : Off Ctrl
Enable MCA promotion                     : NotImpl
Enable BERR promotion                    : NotImpl
cobra:~ #  
--------------------------------------------------------------

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/palinfo.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

Index: test/arch/ia64/kernel/palinfo.c
=================================--- test.orig/arch/ia64/kernel/palinfo.c	2006-10-18 17:17:47.000000000 -0500
+++ test/arch/ia64/kernel/palinfo.c	2006-10-26 15:09:57.369110755 -0500
@@ -16,6 +16,7 @@
  * 02/05/2001   S.Eranian	fixed module support
  * 10/23/2001	S.Eranian	updated pal_perf_mon_info bug fixes
  * 03/24/2004	Ashok Raj	updated to work with CPU Hotplug
+ * 10/26/2006   Russ Anderson	updated processor features to rev 2.2 spec
  */
 #include <linux/types.h>
 #include <linux/errno.h>
@@ -467,7 +468,11 @@ static const char *proc_features[]={
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL, NULL,NULL,NULL,NULL,
-	NULL,NULL,NULL,NULL,NULL,
+	"Unimplemented instruction address fault",
+	"INIT, PMI, and LINT pins",
+	"Simple unimplimented instr addresses",
+	"Variable P-state performance",
+	"Virtual machine features implemeted",
 	"XIP,XPSR,XFS implemented",
 	"XR1-XR3 implemented",
 	"Disable dynamic predicate prediction",
@@ -475,7 +480,11 @@ static const char *proc_features[]={
 	"Disable dynamic data cache prefetch",
 	"Disable dynamic inst cache prefetch",
 	"Disable dynamic branch prediction",
-	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL,
+	"Disable P-states",
+	"Enable MCA on Data Poisoning",
+	"Enable vmsw instruction",
+	"Enable extern environmental notification",
 	"Disable BINIT on processor time-out",
 	"Disable dynamic power management (DPM)",
 	"Disable coherency",
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
