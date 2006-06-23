From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 23 Jun 2006 19:15:55 +0000
Subject: [PATCH] Format /proc/pal/*/version_info correctly
Message-Id: <20060623191555.GB1611@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


/proc/pal/*/version_info is a bit confusing.  HP firmware, at least,
reports 07.31 instead of 0.7.31.  Also, the comment is out of place;
it's an internal detail about the implementation of ia64_pal_version.
Since the 2.2 revision of the SDM still states that PAL_VERSION can
be called in virtual mode, correct the comment to be more accurate.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: include/asm-ia64/pal.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/pal.h,v
retrieving revision 1.10
diff -u -p -r1.10 pal.h
--- ./include/asm-ia64/pal.h	3 Apr 2006 13:45:51 -0000	1.10
+++ ./include/asm-ia64/pal.h	23 Jun 2006 18:32:49 -0000
@@ -1433,7 +1433,12 @@ typedef union  pal_version_u {
 } pal_version_u_t;
 
 
-/* Return PAL version information */
+/*
+ * Return PAL version information.  While the documentation states that
+ * PAL_VERSION can be called in either physical or virtual mode, some
+ * implementations only allow physical calls.  We don't call it very often,
+ * so the overhead isn't worth eliminating.
+ */
 static inline s64
 ia64_pal_version (pal_version_u_t *pal_min_version, pal_version_u_t *pal_cur_version)
 {
Index: arch/ia64/kernel/palinfo.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/kernel/palinfo.c,v
retrieving revision 1.8
diff -u -p -r1.8 palinfo.c
--- ./arch/ia64/kernel/palinfo.c	27 Apr 2006 04:58:38 -0000	1.8
+++ ./arch/ia64/kernel/palinfo.c	23 Jun 2006 18:32:49 -0000
@@ -567,29 +567,23 @@ version_info(char *page)
 	pal_version_u_t min_ver, cur_ver;
 	char *p = page;
 
-	/* The PAL_VERSION call is advertised as being able to support
-	 * both physical and virtual mode calls. This seems to be a documentation
-	 * bug rather than firmware bug. In fact, it does only support physical mode.
-	 * So now the code reflects this fact and the pal_version() has been updated
-	 * accordingly.
-	 */
-	if (ia64_pal_version(&min_ver, &cur_ver) != 0) return 0;
+	if (ia64_pal_version(&min_ver, &cur_ver) != 0)
+		return 0;
 
 	p += sprintf(p,
 		     "PAL_vendor : 0x%02x (min=0x%02x)\n"
-		     "PAL_A      : %x.%x.%x (min=%x.%x.%x)\n"
-		     "PAL_B      : %x.%x.%x (min=%x.%x.%x)\n",
-		     cur_ver.pal_version_s.pv_pal_vendor, min_ver.pal_version_s.pv_pal_vendor,
-
-		     cur_ver.pal_version_s.pv_pal_a_model>>4,
-		     cur_ver.pal_version_s.pv_pal_a_model&0xf, cur_ver.pal_version_s.pv_pal_a_rev,
-		     min_ver.pal_version_s.pv_pal_a_model>>4,
-		     min_ver.pal_version_s.pv_pal_a_model&0xf, min_ver.pal_version_s.pv_pal_a_rev,
-
-		     cur_ver.pal_version_s.pv_pal_b_model>>4,
-		     cur_ver.pal_version_s.pv_pal_b_model&0xf, cur_ver.pal_version_s.pv_pal_b_rev,
-		     min_ver.pal_version_s.pv_pal_b_model>>4,
-		     min_ver.pal_version_s.pv_pal_b_model&0xf, min_ver.pal_version_s.pv_pal_b_rev);
+		     "PAL_A      : %02x.%02x (min=%02x.%02x)\n"
+		     "PAL_B      : %02x.%02x (min=%02x.%02x)\n",
+		     cur_ver.pal_version_s.pv_pal_vendor,
+		     min_ver.pal_version_s.pv_pal_vendor,
+		     cur_ver.pal_version_s.pv_pal_a_model,
+		     cur_ver.pal_version_s.pv_pal_a_rev,
+		     min_ver.pal_version_s.pv_pal_a_model,
+		     min_ver.pal_version_s.pv_pal_a_rev,
+		     cur_ver.pal_version_s.pv_pal_b_model,
+		     cur_ver.pal_version_s.pv_pal_b_rev,
+		     min_ver.pal_version_s.pv_pal_b_model,
+		     min_ver.pal_version_s.pv_pal_b_rev);
 	return p - page;
 }
 
