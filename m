From: Matthew Wilcox <willy@debian.org>
Date: Mon, 01 Mar 2004 16:05:32 +0000
Subject: [PATCH] sal cleanup
Message-Id: <20040301160532.GX25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch reorganises sal.c and adds a small amount of new functionality.

 - Introduce sal_revision to report what revision of the SAL spec is
   supported by the system.
 - Introduce sal_version to report what version of the vendor's SAL
   implementation is present.
 - Introduce SAL_VERSION_CODE to allow for easy comparisons.
 - Print the version at boot, and remove the 'oem=' and 'vendor=' strings.
 - Refactor ia64_sal_init() into several smaller functions.
 - Delete the dead variables 'max' and 'min'.
 - Stop printing the pal_proc and sal_proc entry addresses.
 - Print "None" if there are no SAL platform features.

Index: arch/ia64/kernel/sal.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/kernel/sal.c,v
retrieving revision 1.2
diff -u -p -r1.2 sal.c
--- a/arch/ia64/kernel/sal.c	28 Feb 2004 01:49:51 -0000	1.2
+++ b/arch/ia64/kernel/sal.c	1 Mar 2004 15:34:04 -0000
@@ -10,7 +10,6 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/smp.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 
@@ -21,6 +20,12 @@
 spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
 unsigned long sal_platform_features;
 
+unsigned short sal_revision;
+unsigned short sal_version;
+
+#define SAL_MAJOR(x) ((x) >> 8)
+#define SAL_MINOR(x) ((x) & 0xff)
+
 static struct {
 	void *addr;	/* function entry point */
 	void *gpval;	/* gp value to use */
@@ -86,13 +91,75 @@ ia64_sal_handler_init (void *entry_point
 	ia64_sal = (ia64_sal_handler) &pdesc;
 }
 
+static void __init sal_desc_entry_point(void *p)
+{
+	struct ia64_sal_desc_entry_point *ep = p;
+	ia64_pal_handler_init(__va(ep->pal_proc));
+	ia64_sal_handler_init(__va(ep->sal_proc), __va(ep->gp));
+}
+
+#ifdef CONFIG_SMP
+static void __init set_smp_redirect(int flag)
+{
+	if (no_int_routing)
+		smp_int_redirect &= ~flag;
+	else
+		smp_int_redirect |= flag;
+}
+#else
+static void __init set_smp_redirect(int flag) { }
+#endif
+
+static void __init sal_desc_platform_feature(void *p)
+{
+	struct ia64_sal_desc_platform_feature *pf = p;
+	sal_platform_features = pf->feature_mask;
+
+	printk(KERN_INFO "SAL Platform features:");
+	if (!sal_platform_features) {
+		printk(" None\n");
+		return;
+	}
+
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_BUS_LOCK)
+		printk(" BusLock");
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT) {
+		printk(" IRQ_Redirection");
+		set_smp_redirect(SMP_IRQ_REDIRECTION);
+	}
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT) {
+		printk(" IPI_Redirection");
+		set_smp_redirect(SMP_IPI_REDIRECTION);
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
@@ -103,85 +170,35 @@ ia64_sal_init (struct ia64_sal_systab *s
 	if (strncmp(systab->signature, "SST_", 4) != 0)
 		printk(KERN_ERR "bad signature in system table!");
 
-	/*
-	 * revisions are coded in BCD, so %x does the job for us
-	 */
-	printk(KERN_INFO "SAL v%x.%x: oem=%.32s, product=%.32s\n",
-	       systab->sal_rev_major, systab->sal_rev_minor,
-	       systab->oem_id, systab->product_id);
+	sal_revision = (systab->sal_rev_major << 8) | systab->sal_rev_minor;
+	sal_version = (systab->sal_b_rev_major << 8) | systab->sal_b_rev_minor;
 
-	min = ~0UL;
-	max = 0;
+	/* revisions are coded in BCD, so %x does the job for us */
+	printk(KERN_INFO "SAL %x.%x: %.32s %.32s%sversion %x.%x\n",
+			SAL_MAJOR(sal_revision), SAL_MINOR(sal_revision),
+			systab->oem_id, systab->product_id,
+			systab->product_id[0] ? " " : "",
+			SAL_MAJOR(sal_version), SAL_MINOR(sal_version));
 
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
Index: include/asm-ia64/sal.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/sal.h,v
retrieving revision 1.4
diff -u -p -r1.4 sal.h
--- a/include/asm-ia64/sal.h	7 Jan 2004 21:30:42 -0000	1.4
+++ b/include/asm-ia64/sal.h	1 Mar 2004 15:34:07 -0000
@@ -35,6 +35,7 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/bcd.h>
 #include <linux/spinlock.h>
 #include <linux/efi.h>
 
@@ -229,6 +230,10 @@ typedef struct ia64_sal_desc_ap_wakeup {
 extern ia64_sal_handler ia64_sal;
 extern struct ia64_sal_desc_ptc *ia64_ptc_domain_info;
 
+extern unsigned short sal_revision;	/* supported SAL spec revision */
+extern unsigned short sal_version;	/* SAL version; OEM dependent */
+#define SAL_VERSION_CODE(major, minor) ((BIN2BCD(major) << 8) | BIN2BCD(minor))
+
 extern const char *ia64_sal_strerror (long status);
 extern void ia64_sal_init (struct ia64_sal_systab *sal_systab);
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
