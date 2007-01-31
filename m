From: Aron Griffis <aron@hp.com>
Date: Wed, 31 Jan 2007 01:00:43 +0000
Subject: [PATCH] use snprintf() on features
Message-Id: <20070131010042.GC20942@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some patches have turned up on xen-devel recently to convert strcpy()
to safer alternatives and so forth.  While reviewing those patches
I noticed that the features string building could be cleaned up.

This patch uses snprintf() instead of strcpy() and direct character
pointer manipulation.  It makes the features string building safe and
gets rid of the special case for features output in show_cpuinfo()

Additionally I removed the (int) cast of ARRAY_SIZE, which seems to
serve no purpose.

Tested by cat /proc/cpuinfo on Montecito

Signed-off-by: Aron Griffis <aron@hp.com>

 setup.c |   33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff -r 32ea132ddbfb arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Tue Jan 30 08:46:17 2007 -0800
+++ b/arch/ia64/kernel/setup.c	Tue Jan 30 18:11:07 2007 -0500
@@ -569,34 +569,31 @@ show_cpuinfo (struct seq_file *m, void *
 		{ 1UL << 1, "spontaneous deferral"},
 		{ 1UL << 2, "16-byte atomic ops" }
 	};
-	char features[128], *cp, sep;
+	char features[128], *cp, *sep;
 	struct cpuinfo_ia64 *c = v;
 	unsigned long mask;
 	unsigned long proc_freq;
-	int i;
+	int i, size;
 
 	mask = c->features;
 
 	/* build the feature string: */
-	memcpy(features, " standard", 10);
+	memcpy(features, "standard", 9);
 	cp = features;
-	sep = 0;
-	for (i = 0; i < (int) ARRAY_SIZE(feature_bits); ++i) {
+	size = sizeof(features);
+	sep = "";
+	for (i = 0; i < ARRAY_SIZE(feature_bits) && size > 1; ++i) {
 		if (mask & feature_bits[i].mask) {
-			if (sep)
-				*cp++ = sep;
-			sep = ',';
-			*cp++ = ' ';
-			strcpy(cp, feature_bits[i].feature_name);
-			cp += strlen(feature_bits[i].feature_name);
+			cp += snprintf(cp, size, "%s%s", sep, 
+				       feature_bits[i].feature_name),
+			sep = ", ";
 			mask &= ~feature_bits[i].mask;
 		}
-	}
-	if (mask) {
-		/* print unknown features as a hex value: */
-		if (sep)
-			*cp++ = sep;
-		sprintf(cp, " 0x%lx", mask);
+		size = sizeof(features) - (cp - features);
+	}
+	if (mask && size > 1) {
+		/* print unknown features as a hex value */
+		snprintf(cp, size, "%s0x%lx", sep, mask);
 	}
 
 	proc_freq = cpufreq_quick_get(cpunum);
@@ -612,7 +609,7 @@ show_cpuinfo (struct seq_file *m, void *
 		   "model name : %s\n"
 		   "revision   : %u\n"
 		   "archrev    : %u\n"
-		   "features   :%s\n"	/* don't change this---it _is_ right! */
+		   "features   : %s\n"
 		   "cpu number : %lu\n"
 		   "cpu regs   : %u\n"
 		   "cpu MHz    : %lu.%06lu\n"
