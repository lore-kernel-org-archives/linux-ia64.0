From: Russ Anderson <rja@sgi.com>
Date: Tue, 16 Oct 2007 22:02:38 +0000
Subject: [patch] Update printing of feature set bits
Message-Id: <20071016220238.GB1898@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Update printing of feature set bits

Newer Itanium versions have added additional processor feature set
bits.  This patch prints all the implemented feature set bits.  Some
bit descriptions have not been made public.  For those bits, a generic
"Feature set X bit Y" message is printed.  Bits that are not implemented
will no longer be printed.

Signed-off-by: Russ Anderson <rja@sgi.com>

Sample Montecito output (old):
----------------------------------------------------
cobra:~ # cat /proc/pal/cpu0/processor_info
Unimplemented instruction address fault  : NotImpl
INIT, PMI, and LINT pins                 : NotImpl
Simple unimplemented instr addresses     : On NoCtrl
Variable P-state performance             : NotImpl
Virtual machine features implemented     : On NoCtrl
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
----------------------------------------------------

Sample Montecito output (new):
----------------------------------------------------
cobra:~ # cat /proc/pal/cpu0/processor_info
Simple unimplemented instr addresses     : On  NoCtrl
Virtual machine features implemented     : On  NoCtrl
XIP,XPSR,XFS implemented                 : On  NoCtrl
XR1-XR3 implemented                      : On  NoCtrl
Disable P-states                         : Off Ctrl
Enable MCA on Data Poisoning             : Off Ctrl
Enable vmsw instruction                  : On  Ctrl
Disable BINIT on processor time-out      : On  Ctrl
Enable CMCI promotion                    : Off Ctrl
Enable MCA to BINIT promotion            : Off Ctrl
Disable ETM                              : Off Ctrl
Enable ETM                               : Off Ctrl
Enable MCA on half-way timer             : Off Ctrl
Enable Fast Deferral                     : Off Ctrl
Disable MCA on memory aliasing           : Off Ctrl
Enable RSB                               : On  Ctrl
Feature set 17 bit  0                    : Off Ctrl
Feature set 18 bit  0                    : Off Ctrl
Feature set 18 bit  1                    : Off Ctrl
Feature set 18 bit  3                    : Off Ctrl
Feature set 18 bit  4                    : On  Ctrl
Feature set 18 bit  5                    : On  Ctrl
Feature set 18 bit  6                    : Off Ctrl
Feature set 18 bit  7                    : Off Ctrl
Feature set 18 bit  9                    : Off Ctrl
Feature set 18 bit 10                    : Off Ctrl
Feature set 18 bit 11                    : Off Ctrl
Feature set 18 bit 12                    : Off Ctrl
Feature set 18 bit 13                    : Off Ctrl
----------------------------------------------------



---
 arch/ia64/kernel/palinfo.c |   91 +++++++++++++++++++++++++++++++++++++++------
 include/asm-ia64/pal.h     |    5 +-
 2 files changed, 82 insertions(+), 14 deletions(-)

Index: test/include/asm-ia64/pal.h
=================================--- test.orig/include/asm-ia64/pal.h	2007-10-16 16:18:37.266479139 -0500
+++ test/include/asm-ia64/pal.h	2007-10-16 16:19:00.393327699 -0500
@@ -1379,10 +1379,11 @@ struct pal_features_s;
 static inline s64
 ia64_pal_proc_get_features (u64 *features_avail,
 			    u64 *features_status,
-			    u64 *features_control)
+			    u64 *features_control,
+			    u64 features_set)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL_PHYS(iprv, PAL_PROC_GET_FEATURES, 0, 0, 0);
+	PAL_CALL_PHYS(iprv, PAL_PROC_GET_FEATURES, 0, features_set, 0);
 	if (iprv.status = 0) {
 		*features_avail   = iprv.v0;
 		*features_status  = iprv.v1;
Index: test/arch/ia64/kernel/palinfo.c
=================================--- test.orig/arch/ia64/kernel/palinfo.c	2007-10-16 16:18:37.266479139 -0500
+++ test/arch/ia64/kernel/palinfo.c	2007-10-16 16:19:27.476663557 -0500
@@ -470,7 +470,7 @@ register_info(char *page)
 	return p - page;
 }
 
-static const char *proc_features[]={
+static char *proc_features_0[]={		/* Feature set 0 */
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
@@ -502,25 +502,92 @@ static const char *proc_features[]={
 	"Enable BERR promotion"
 };
 
+static char *proc_features_16[]={		/* Feature set 16 */
+	"Disable ETM",
+	"Enable ETM",
+	"Enable MCA on half-way timer",
+	"Enable snoop WC",
+	NULL,
+	"Enable Fast Deferral",
+	"Disable MCA on memory aliasing",
+	"Enable RSB",
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	"DP system processor",
+	"Low Voltage",
+	"HT supported",
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL, NULL
+};
+
+static char **proc_features[]={
+	proc_features_0,
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL,
+	proc_features_16,
+	NULL, NULL, NULL, NULL,
+};
+
+static char *
+feature_set_info(char *page, u64 avail, u64 status, u64 control, u64 set)
+{
+	char *p = page;
+	char **vf, **v;
+	int i;
+
+	vf = v = proc_features[set];
+	for(i=0; i < 64; i++, avail >>=1, status >>=1, control >>=1) {
+
+		if (!(control))		/* No remaining bits set */
+			break;
+		if (!(avail & 0x1))	/* Print only bits that are available */
+			continue;
+		if (vf)
+			v = vf + i;
+		if ( v && *v ) {
+			p += sprintf(p, "%-40s : %s %s\n", *v,
+				avail & 0x1 ? (status & 0x1 ?
+						"On " : "Off"): "",
+				avail & 0x1 ? (control & 0x1 ?
+						"Ctrl" : "NoCtrl"): "");
+		} else {
+			p += sprintf(p, "Feature set %2ld bit %2d\t\t\t"
+					" : %s %s\n",
+				set, i,
+				avail & 0x1 ? (status & 0x1 ?
+						"On " : "Off"): "",
+				avail & 0x1 ? (control & 0x1 ?
+						"Ctrl" : "NoCtrl"): "");
+		}
+	}
+	return p;
+}
 
 static int
 processor_info(char *page)
 {
 	char *p = page;
-	const char **v = proc_features;
-	u64 avail=1, status=1, control=1;
-	int i;
+	u64 avail=1, status=1, control=1, feature_set=0;
 	s64 ret;
 
-	if ((ret=ia64_pal_proc_get_features(&avail, &status, &control)) != 0) return 0;
+	do {
+		ret = ia64_pal_proc_get_features(&avail, &status, &control,
+						feature_set);
+		if (ret < 0) {
+			return p - page;
+		}
+		if (ret = 1) {
+			feature_set++;
+			continue;
+		}
+
+		p = feature_set_info(p, avail, status, control, feature_set);
+
+		feature_set++;
+	} while(1);
 
-	for(i=0; i < 64; i++, v++,avail >>=1, status >>=1, control >>=1) {
-		if ( ! *v ) continue;
-		p += sprintf(p, "%-40s : %s%s %s\n", *v,
-				avail & 0x1 ? "" : "NotImpl",
-				avail & 0x1 ? (status & 0x1 ? "On" : "Off"): "",
-				avail & 0x1 ? (control & 0x1 ? "Ctrl" : "NoCtrl"): "");
-	}
 	return p - page;
 }
 
-- 
Russ Anderson  RAS group  SGI  rja@sgi.com
