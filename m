From: Matthew Wilcox <willy@debian.org>
Date: Thu, 26 Feb 2004 21:37:04 +0000
Subject: [PATCH] sal cleanup
Message-Id: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch reorganises sal.c and adds two new functions:

 - Split the body of the switch statement in ia64_sal_init() into
   separate functions.
 - Delete min/max since they were only assigned to, never used.
 - Print the version of the SAL implementation as well as the spec version
   it supports.
 - Stop printing the pal_proc and sal_proc entry addresses.
 - Don't print the SAL platform features line if there's no features.
 - Remember the sal revision and version and add two functions to compare them.

Index: arch/ia64/kernel/sal.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/kernel/sal.c,v
retrieving revision 1.1
diff -u -p -r1.1 sal.c
--- a/arch/ia64/kernel/sal.c	29 Jul 2003 17:00:27 -0000	1.1
+++ b/arch/ia64/kernel/sal.c	26 Feb 2004 21:33:26 -0000
@@ -8,9 +8,9 @@
  */
 #include <linux/config.h>
 
+#include <linux/bcd.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/smp.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 
@@ -21,6 +21,9 @@
 spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
 unsigned long sal_platform_features;
 
+int sal_rev_major, sal_rev_minor;
+int sal_b_rev_major, sal_b_rev_minor;
+
 static struct {
 	void *addr;	/* function entry point */
 	void *gpval;	/* gp value to use */
@@ -86,13 +89,70 @@ ia64_sal_handler_init (void *entry_point
 	ia64_sal = (ia64_sal_handler) &pdesc;
 }
 
+static void __init sal_desc_entry_point(void *p)
+{
+	struct ia64_sal_desc_entry_point *ep = p;
+	ia64_pal_handler_init(__va(ep->pal_proc));
+	ia64_sal_handler_init(__va(ep->sal_proc), __va(ep->gp));
+}
+
+static void __init sal_desc_platform_feature(void *p)
+{
+	struct ia64_sal_desc_platform_feature *pf = p;
+	sal_platform_features = pf->feature_mask;
+	if (!sal_platform_features)
+		return;
+
+	printk(KERN_INFO "SAL: Platform features");
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_BUS_LOCK)
+		printk(" BusLock");
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT) {
+		printk(" IRQ_Redirection");
+#ifdef CONFIG_SMP
+		if (no_int_routing)
+			smp_int_redirect &= ~SMP_IRQ_REDIRECTION;
+		else
+			smp_int_redirect |= SMP_IRQ_REDIRECTION;
+#endif
+	}
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT) {
+		printk(" IPI_Redirection");
+#ifdef CONFIG_SMP
+		if (no_int_routing)
+			smp_int_redirect &= ~SMP_IPI_REDIRECTION;
+		else
+			smp_int_redirect |= SMP_IPI_REDIRECTION;
+#endif
+	}
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)
+		printk(" ITC_Drift");
+	printk("\n");
+}
+
+#ifdef CONFIG_SMP
+static void __init sal_desc_ap_wakeup(void *p)
+{
+	struct ia64_sal_desc_ap_wakeup *ap = p;
+	
+	switch (ap->mechanism) {
+	case IA64_SAL_AP_EXTERNAL_INT:
+		ap_wakeup_vector = ap->vector;
+		printk(KERN_INFO "SAL: AP wakeup using external interrupt "
+				"vector 0x%lx\n", ap_wakeup_vector);
+		break;
+	default:
+		printk(KERN_ERR "SAL: AP wakeup mechanism unsupported!\n");
+		break;
+	}
+}
+#else
+static void __init sal_desc_ap_wakeup(void *p) { }
+#endif
 
 void __init
 ia64_sal_init (struct ia64_sal_systab *systab)
 {
-	unsigned long min, max;
 	char *p;
-	struct ia64_sal_desc_entry_point *ep;
 	int i;
 
 	if (!systab) {
@@ -103,86 +163,73 @@ ia64_sal_init (struct ia64_sal_systab *s
 	if (strncmp(systab->signature, "SST_", 4) != 0)
 		printk(KERN_ERR "bad signature in system table!");
 
-	/*
-	 * revisions are coded in BCD, so %x does the job for us
-	 */
-	printk(KERN_INFO "SAL v%x.%02x: oem=%.32s, product=%.32s\n",
-	       systab->sal_rev_major, systab->sal_rev_minor,
-	       systab->oem_id, systab->product_id);
-
-	min = ~0UL;
-	max = 0;
+	sal_rev_major = BCD2BIN(systab->sal_rev_major);
+	sal_rev_minor = BCD2BIN(systab->sal_rev_minor);
+	sal_b_rev_major = BCD2BIN(systab->sal_b_rev_major);
+	sal_b_rev_minor = BCD2BIN(systab->sal_b_rev_minor);
+
+	printk(KERN_INFO "SAL %d.%d: oem=%.32s, product=%.32s, version %d.%d\n",
+			sal_rev_major, sal_rev_minor, systab->oem_id,
+			systab->product_id, sal_b_rev_major, sal_b_rev_minor);
 
 	p = (char *) (systab + 1);
 	for (i = 0; i < systab->entry_count; i++) {
 		/*
-		 * The first byte of each entry type contains the type descriptor.
+		 * The first byte of each entry type contains the type
+		 * descriptor.
 		 */
 		switch (*p) {
-		      case SAL_DESC_ENTRY_POINT:
-			ep = (struct ia64_sal_desc_entry_point *) p;
-			printk(KERN_INFO "SAL: entry: pal_proc=0x%lx, sal_proc=0x%lx\n",
-			       ep->pal_proc, ep->sal_proc);
-			ia64_pal_handler_init(__va(ep->pal_proc));
-			ia64_sal_handler_init(__va(ep->sal_proc), __va(ep->gp));
+		case SAL_DESC_ENTRY_POINT:
+			sal_desc_entry_point(p);
 			break;
-
-		      case SAL_DESC_PTC:
+		case SAL_DESC_PLATFORM_FEATURE:
+			sal_desc_platform_feature(p);
+			break;
+		case SAL_DESC_PTC:
 			ia64_ptc_domain_info = (ia64_sal_desc_ptc_t *)p;
 			break;
-
-		      case SAL_DESC_AP_WAKEUP:
-#ifdef CONFIG_SMP
-		      {
-			      struct ia64_sal_desc_ap_wakeup *ap = (void *) p;
-
-			      switch (ap->mechanism) {
-				    case IA64_SAL_AP_EXTERNAL_INT:
-				      ap_wakeup_vector = ap->vector;
-				      printk(KERN_INFO "SAL: AP wakeup using external interrupt "
-					     "vector 0x%lx\n", ap_wakeup_vector);
-				      break;
-
-				    default:
-				      printk(KERN_ERR "SAL: AP wakeup mechanism unsupported!\n");
-				      break;
-			      }
-			      break;
-		      }
-#endif
-		      case SAL_DESC_PLATFORM_FEATURE:
-		      {
-			      struct ia64_sal_desc_platform_feature *pf = (void *) p;
-			      sal_platform_features = pf->feature_mask;
-			      printk(KERN_INFO "SAL: Platform features ");
-
-			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_BUS_LOCK)
-				      printk("BusLock ");
-			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT) {
-				      printk("IRQ_Redirection ");
-#ifdef CONFIG_SMP
-				      if (no_int_routing)
-					      smp_int_redirect &= ~SMP_IRQ_REDIRECTION;
-				      else
-					      smp_int_redirect |= SMP_IRQ_REDIRECTION;
-#endif
-			      }
-			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT) {
-				      printk("IPI_Redirection ");
-#ifdef CONFIG_SMP
-				      if (no_int_routing)
-					      smp_int_redirect &= ~SMP_IPI_REDIRECTION;
-				      else
-					      smp_int_redirect |= SMP_IPI_REDIRECTION;
-#endif
-			      }
-			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)
-				      printk("ITC_Drift ");
-			      printk("\n");
-			      break;
- 		      }
-
+		case SAL_DESC_AP_WAKEUP:
+			sal_desc_ap_wakeup(p);
+			break;
 		}
 		p += SAL_DESC_SIZE(*p);
 	}
+}
+
+/**
+ * sal_check_revision - Check the revision of the SAL spec supported by firmware
+ * @major: The major number of the SAL spec
+ * @minor: The minor number of the SAL spec
+ *
+ * This function returns 1 if the SAL implementation on this machine
+ * supports the required revision.  Use it as:
+ *
+ * if (sal_check_revision(3, 2)) { ... }
+ */
+int sal_check_revision(int major, int minor)
+{
+	if (major < sal_rev_major)
+		return 1;
+	if (major > sal_rev_major)
+		return 0;
+	return (minor <= sal_rev_minor);
+}
+
+/**
+ * sal_check_version - Check what version of SAL is installed
+ * @major: The major number of the implementation
+ * @minor: The minor number of the implementation
+ *
+ * This function returns 1 if the version of the implementation of SAL is
+ * equal or higher than the required version.  You can only use this function
+ * if you already know what manufacturer your SAL comes from as every vendor
+ * may have a different version.
+ */
+int sal_check_version(int major, int minor)
+{
+	if (major < sal_b_rev_major)
+		return 1;
+	if (major > sal_b_rev_major)
+		return 0;
+	return (minor <= sal_b_rev_minor);
 }
Index: include/asm-ia64/sal.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/sal.h,v
retrieving revision 1.4
diff -u -p -r1.4 sal.h
--- a/include/asm-ia64/sal.h	7 Jan 2004 21:30:42 -0000	1.4
+++ b/include/asm-ia64/sal.h	26 Feb 2004 21:33:26 -0000
@@ -231,6 +231,8 @@ extern struct ia64_sal_desc_ptc *ia64_pt
 
 extern const char *ia64_sal_strerror (long status);
 extern void ia64_sal_init (struct ia64_sal_systab *sal_systab);
+extern int sal_check_revision(int major, int minor);
+extern int sal_check_version(int major, int minor);
 
 /* SAL information type encodings */
 enum {

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
