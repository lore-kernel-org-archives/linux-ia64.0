From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 28 Sep 2004 21:57:18 +0000
Subject: [PATCH] sn2: serialize access to PROM chips
Message-Id: <200409281457.18454.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_+4dWBEG8gLO4F8W"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_+4dWBEG8gLO4F8W
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

If we read and write the PROM chips at the same time, as might happen at boot 
when salinfo extracts MCA records and a user is checking the PROM revision 
in /proc/sgi_prominfo, an MCA might occur, since the PROM chips can't be 
accessed that way.  This patch fixes the problem for systems with new PROMs 
(>= 3.50) by using the SAL to do PROM reads.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_+4dWBEG8gLO4F8W
Content-Type: text/plain;
  charset="us-ascii";
  name="prom-chip-locking-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="prom-chip-locking-2.patch"

===== arch/ia64/sn/kernel/sn2/prominfo_proc.c 1.6 vs edited =====
--- 1.6/arch/ia64/sn/kernel/sn2/prominfo_proc.c	2004-09-15 15:58:59 -07:00
+++ edited/arch/ia64/sn/kernel/sn2/prominfo_proc.c	2004-09-28 10:12:20 -07:00
@@ -14,50 +14,14 @@
 #include <linux/proc_fs.h>
 #include <asm/system.h>
 #include <asm/io.h>
-#include <asm/sn/sn2/addrs.h>
-#include <asm/sn/simulator.h>
-
-/* to lookup nasids */
+#include <asm/sn/sn_sal.h>
 #include <asm/sn/sn_cpuid.h>
+#include <asm/sn/sn2/addrs.h>
 
 MODULE_DESCRIPTION("PROM version reporting for /proc");
 MODULE_AUTHOR("Chad Talbott");
 MODULE_LICENSE("GPL");
 
-#undef DEBUG_PROMINFO
-
-#define TRACE_PROMINFO
-
-#if defined(DEBUG_PROMINFO)
-#  define DPRINTK(x...) printk(KERN_DEBUG x)
-#else
-#  define DPRINTK(x...)
-#endif
-
-#if defined(TRACE_PROMINFO) && defined(DEBUG_PROMINFO)
-#  if defined(__GNUC__)
-#    define TRACE()	printk(KERN_DEBUG "%s:%d:%s\n", \
-			       __FILE__, __LINE__, __FUNCTION__)
-#  else
-#    define TRACE()	printk(KERN_DEBUG "%s:%d\n", __LINE__, __FILE__)
-#  endif
-#else
-#  define TRACE()
-#endif
-
-/* Architected IA64 firmware space */
-#define FW_BASE			0x00000000FF000000
-#define FW_TOP			0x0000000100000000
-
-/* Sub-regions determined by bits in Node Offset */
-#define	LB_PROM_SPACE		0x0000000700000000ul /* Local LB PROM */
-
-/* Offset of PROM banner pointers in SAL A and SAL B */
-#define SAL_A_BANNER_OFFSET	(1 * 16)
-#define SAL_B_BANNER_OFFSET	(3 * 16)
-
-
-#define FIT_SIGNATURE		0x2020205f5449465ful
 /* Standard Intel FIT entry types */
 #define FIT_ENTRY_FIT_HEADER	0x00	/* FIT header entry */
 #define FIT_ENTRY_PAL_B		0x01	/* PAL_B entry */
@@ -90,12 +54,6 @@
 #define FIT_TYPE(q)	\
 	((unsigned) ((q) >> FIT_TYPE_SHIFT) & FIT_TYPE_MASK)
 
-#define FIT_ENTRY(type, maj, min, size)					\
-	((((unsigned long)(maj) & FIT_MAJOR_MASK) << FIT_MAJOR_SHIFT) |	\
-	 (((unsigned long)(min) & FIT_MINOR_MASK) << FIT_MINOR_SHIFT) |	\
-	 (((unsigned long)(type) & FIT_TYPE_MASK) << FIT_TYPE_SHIFT) |	\
-	 (size))
-
 struct fit_type_map_t {
 	unsigned char	type;
 	const char	*name;
@@ -134,6 +92,39 @@
 	return "Unknown type";
 }
 
+
+/* ============ BEGIN temp til old PROMs are no longer supported =============
+ *
+ * The OS should not make direct access to the PROM flash memory. Access to
+ * this region must be serialized with a PROM lock. If SAL on one cpu is
+ * updating the FLASH error log at the same time another cpu is accessing the
+ * PROM, data corruption will occur.
+ *
+ * To solve the problem, all flash PROM access has been moved to SAL. Because
+ * not all systems will have instant PROM updates, we need to support a new OS
+ * running on a system with old PROMs.
+ *
+ * This code should be deleted after 1 OS/PROM release has occurred & the OS
+ * no longer supports downrev PROMs. (PROM support should be in the 3.50
+ * PROMs).
+ */
+#define SUPPORT_OLD_PROMS
+#ifdef SUPPORT_OLD_PROMS
+
+
+#define FIT_SIGNATURE		0x2020205f5449465ful
+
+/* Sub-regions determined by bits in Node Offset */
+#define	LB_PROM_SPACE		0x0000000700000000ul /* Local LB PROM */
+
+/* Offset of PROM banner pointers in SAL A and SAL B */
+#define SAL_A_BANNER_OFFSET	(1 * 16)
+#define SAL_B_BANNER_OFFSET	(3 * 16)
+
+/* Architected IA64 firmware space */
+#define FW_BASE                 0x00000000FF000000
+#define FW_TOP                  0x0000000100000000
+
 static unsigned long
 convert_fw_addr(nasid_t nasid, unsigned long addr)
 {
@@ -154,32 +145,95 @@
 	return (addr >= FW_BASE && addr < FW_TOP);
 }
 
-/* These two routines read the FIT table directly from the FLASH PROM
- * on a specific node.  The PROM can only be accessed using aligned 64
- * bit reads, so we do that and then shift and mask the result to get
- * at each field.
+static unsigned long *
+lookup_fit(int nasid)
+{
+	unsigned long *fitp;
+	unsigned long fit_paddr;
+	unsigned long *fit_vaddr;
+
+	fitp = (void *)GLOBAL_MMR_ADDR(nasid, LB_PROM_SPACE - 32);
+	fit_paddr = readq(fitp);
+	fit_vaddr = (unsigned long *) convert_fw_addr(nasid, fit_paddr);
+	return fit_vaddr;
+}
+#endif /* SUPPORT_OLD_PROMS */
+/* ============ END temp til old PROMs are no longer supported ============= */
+
+static int
+get_fit_entry(unsigned long nasid, int index, unsigned long *fentry,
+	      char *banner, int banlen)
+{
+	int ret;
+
+	ret = ia64_sn_get_fit_compt(nasid, index, fentry, banner, banlen);
+
+#ifdef SUPPORT_OLD_PROMS
+	/* The following is hack is temporary until PROMs are updated */
+	if (ret == SALRET_NOT_IMPLEMENTED) {
+		unsigned long *fitadr = lookup_fit(nasid);
+		int nentries;
+
+		if (readq(fitadr) != FIT_SIGNATURE) {
+			printk(KERN_WARNING "Unrecognized FIT signature");
+			return -2;
+		}
+
+		nentries = (unsigned int) (readq(fitadr + 1) & 0xffffff);
+		if (index >= nentries)
+			return -2;
+
+		fentry[0] = readq(fitadr + 2 * index);
+		fentry[1] = readq(fitadr + 2 * index + 1);
+		ret = 0;
+
+		if (banner && FIT_TYPE(fentry[1]) == FIT_ENTRY_SAL_A) {
+			unsigned long i, qw, *bwp, *qwp;
+
+			banner[0] = '\0';
+			qw = fentry[0];	/* Address of SAL A */
+			if (!valid_fw_addr(qw))
+				return 0;
+
+			qw += SAL_A_BANNER_OFFSET;
+			qw = convert_fw_addr(nasid, qw);
+
+			qw = readq(qw);			/* Address of banner */
+			if (!valid_fw_addr(qw))
+				return 0;
+			qw = convert_fw_addr(nasid, qw);
+			qwp = (unsigned long *) qw;
+			bwp = (unsigned long *) banner;
+			for (i=0; i<banlen/8; i++)
+				bwp[i] = qwp[i];
+		}
+	}
+#endif /* SUPPORT_OLD_PROMS */
+	return ret;
+}
+
+
+/*
+ * These two routines display the FIT table for each node.
  */
 static int
 dump_fit_entry(char *page, unsigned long *fentry)
 {
-	unsigned long q1, q2;
 	unsigned type;
 
-	TRACE();
-
-	q1 = readq(fentry);
-	q2 = readq(fentry + 1);
-	type = FIT_TYPE(q2);
+	type = FIT_TYPE(fentry[1]);
 	return sprintf(page, "%02x %-25s %x.%02x %016lx %u\n",
 		       type,
 		       fit_type_name(type),
-		       FIT_MAJOR(q2), FIT_MINOR(q2),
-		       q1,
+		       FIT_MAJOR(fentry[1]), FIT_MINOR(fentry[1]),
+		       fentry[0],
 		       /* mult by sixteen to get size in bytes */
-		       (unsigned)q2 * 16);
+		       (unsigned)(fentry[1] & 0xffffff) * 16);
 }
 
-/* We assume that the fit table will be small enough that we can print
+
+/*
+ * We assume that the fit table will be small enough that we can print
  * the whole thing into one page.  (This is true for our default 16kB
  * pages -- each entry is about 60 chars wide when printed.)  I read
  * somewhere that the maximum size of the FIT is 128 entries, so we're
@@ -187,77 +241,46 @@
  * anyway).
  */
 static int
-dump_fit(char *page, unsigned long *fit)
+dump_fit(char *page, unsigned long nasid)
 {
-	unsigned long qw;
-	int nentries;
-	int fentry;
+	unsigned long fentry[2];
+	int index;
 	char *p;
 
-	TRACE();
-
-	DPRINTK("dumping fit from %p\n", (void *)fit);
-
-	qw = readq(fit);
-	DPRINTK("FIT signature: %016lx (%.8s)\n", qw, (char *)&qw);
-	if (qw != FIT_SIGNATURE)
-		printk(KERN_WARNING "Unrecognized FIT signature");
-
-	qw = readq(fit + 1);
-	nentries = (unsigned)qw;
-	DPRINTK("number of fit entries: %u\n", nentries);
-	/* check that we won't overflow the page -- see comment above */
-	BUG_ON(nentries * 60 > PAGE_SIZE);
-
 	p = page;
-	for (fentry = 0; fentry < nentries; fentry++)
-		/* each FIT entry is two 64 bit words */
-		p += dump_fit_entry(p, fit + 2 * fentry);
+	for (index=0;;index++) {
+		BUG_ON(index * 60 > PAGE_SIZE);
+		if (get_fit_entry(nasid, index, fentry, NULL, 0))
+			break;
+		p += dump_fit_entry(p, fentry);
+	}
 
 	return p - page;
 }
 
 static int
-dump_version(char *page, unsigned long *fit)
+dump_version(char *page, unsigned long nasid)
 {
-	int nentries;
-	int fentry;
-	unsigned long qw = 0;
+	unsigned long fentry[2];
+	char banner[128];
+	int index;
 	int len;
-	nasid_t nasid = NASID_GET(fit);
-
-	TRACE();
 
-	nentries = (unsigned)readq(fit + 1);
-	BUG_ON(nentries * 60 > PAGE_SIZE);
-
-	for (fentry = 0; fentry < nentries; fentry++) {
-		qw = readq(fit + 2 * fentry + 1);
-		if (FIT_TYPE(qw) == FIT_ENTRY_SAL_A)
+	for (index = 0; ; index++) {
+		if (get_fit_entry(nasid, index, fentry, banner,
+				  sizeof(banner)))
+			return 0;
+		if (FIT_TYPE(fentry[1]) == FIT_ENTRY_SAL_A)
 			break;
 	}
-	if (fentry >= nentries)
-		return 0;
 
-	len = sprintf(page, "%x.%02x\n", FIT_MAJOR(qw), FIT_MINOR(qw));
+	len = sprintf(page, "%x.%02x\n", FIT_MAJOR(fentry[1]),
+		      FIT_MINOR(fentry[1]));
 	page += len;
 
-	qw = readq(fit + 2 * fentry);	/* Address of SAL A */
-	DPRINTK("SAL A at %p\n", (void *)qw);
-	if (!valid_fw_addr(qw))
-		return len;
-
-	qw += SAL_A_BANNER_OFFSET;
-	qw = convert_fw_addr(nasid, qw);
-	DPRINTK("Banner ptr at %p\n", (void *)qw);
-
-	qw = readq(qw);			/* Address of banner */
-	if (!valid_fw_addr(qw))
-		return len;
-	qw = convert_fw_addr(nasid, qw);
-	DPRINTK("Banner at %p\n", (void *)qw);
+	if (banner[0])
+		len += snprintf(page, PAGE_SIZE-len, "%s\n", banner);
 
-	len += snprintf(page, PAGE_SIZE-len, "%s\n", (char *)qw);
 	return len;
 }
 
@@ -280,8 +303,8 @@
 {
 	int len = 0;
 
-	/* data holds the pointer to this node's FIT */
-	len = dump_version(page, (unsigned long *)data);
+	/* data holds the NASID of the node */
+	len = dump_version(page, (unsigned long)data);
 	len = proc_calc_metrics(page, start, off, count, eof, len);
 	return len;
 }
@@ -292,52 +315,13 @@
 {
 	int len = 0;
 
-	/* data holds the pointer to this node's FIT */
-	len = dump_fit(page, (unsigned long *)data);
+	/* data holds the NASID of the node */
+	len = dump_fit(page, (unsigned long)data);
 	len = proc_calc_metrics(page, start, off, count, eof, len);
 
 	return len;
 }
 
-/* this is a fake FIT that's used on the medusa simulator which
- * doesn't usually run a complete PROM. 
- */
-#ifdef CONFIG_IA64_SGI_SN_SIM
-static unsigned long fakefit[] = {
-	/* this is all we need to satisfy the code below */
-	FIT_SIGNATURE,
-	FIT_ENTRY(FIT_ENTRY_FIT_HEADER, 0x02, 0x60, 2),
-	/* dump something arbitrary for
-	 * /proc/sgi_prominfo/nodeX/version */
-	0xbadbeef00fa3ef17ul,
-	FIT_ENTRY(FIT_ENTRY_SAL_A, 0, 0x99, 0x100)
-};	
-#endif
-
-static unsigned long *
-lookup_fit(int nasid)
-{
-	unsigned long *fitp;
-	unsigned long fit_paddr;
-	unsigned long *fit_vaddr;
-
-#ifdef CONFIG_IA64_SGI_SN_SIM
-	if (IS_RUNNING_ON_SIMULATOR())
-		return fakefit;
-#endif
-
-	fitp = (void *)GLOBAL_MMR_ADDR(nasid, LB_PROM_SPACE - 32);
-	DPRINTK("pointer to fit at %p\n", (void *)fitp);
-	fit_paddr = readq(fitp);
-	DPRINTK("fit pointer contains %lx\n", fit_paddr);
-
-	BUG_ON(!valid_fw_addr(fit_paddr));
-	fit_vaddr = (void *)convert_fw_addr(nasid, fit_paddr);
-
-	DPRINTK("fit at %p\n", (void *)fit_vaddr);
-	return fit_vaddr;
-}
-
 /* module entry points */
 int __init prominfo_init(void);
 void __exit prominfo_exit(void);
@@ -356,17 +340,12 @@
 	struct proc_dir_entry **entp;
 	struct proc_dir_entry *p;
 	cnodeid_t cnodeid;
-	nasid_t nasid;
+	unsigned long nasid;
 	char name[NODE_NAME_LEN];
 
 	if (!ia64_platform_is("sn2"))
 		return 0;
 
-	TRACE();
-
-	DPRINTK("running on cpu %d\n", smp_processor_id());
-	DPRINTK("numnodes %d\n", numnodes);
-
 	proc_entries = kmalloc(numnodes * sizeof(struct proc_dir_entry *),
 			       GFP_KERNEL);
 
@@ -380,12 +359,12 @@
 		nasid = cnodeid_to_nasid(cnodeid);
 		p = create_proc_read_entry(
 			"fit", 0, *entp, read_fit_entry,
-			lookup_fit(nasid));
+			(void *)nasid);
 		if (p)
 			p->owner = THIS_MODULE;
 		p = create_proc_read_entry(
 			"version", 0, *entp, read_version_entry,
-			lookup_fit(nasid));
+			(void *)nasid);
 		if (p)
 			p->owner = THIS_MODULE;
 	}
@@ -399,8 +378,6 @@
 	struct proc_dir_entry **entp;
 	unsigned cnodeid;
 	char name[NODE_NAME_LEN];
-
-	TRACE();
 
 	for (cnodeid = 0, entp = proc_entries;
 	     cnodeid < numnodes;
===== include/asm-ia64/sn/sn_sal.h 1.12 vs edited =====
--- 1.12/include/asm-ia64/sn/sn_sal.h	2004-09-16 15:19:20 -07:00
+++ edited/include/asm-ia64/sn/sn_sal.h	2004-09-28 10:38:21 -07:00
@@ -34,6 +34,7 @@
 #define  SN_SAL_NO_FAULT_ZONE_PHYSICAL		   0x02000011
 #define  SN_SAL_PRINT_ERROR			   0x02000012
 #define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
+#define  SN_SAL_GET_FIT_COMPT			   0x0200001b	// reentrant
 #define  SN_SAL_CONSOLE_PUTC                       0x02000021
 #define  SN_SAL_CONSOLE_GETC                       0x02000022
 #define  SN_SAL_CONSOLE_PUTS                       0x02000023
@@ -107,12 +108,13 @@
 
 
 /*
- * SN_SAL_GET_PARTITION_ADDR return constants
+ * SAL Error Codes
  */
 #define SALRET_MORE_PASSES	1
 #define SALRET_OK		0
-#define SALRET_INVALID_ARG	-2
-#define SALRET_ERROR		-3
+#define SALRET_NOT_IMPLEMENTED	(-1)
+#define SALRET_INVALID_ARG	(-2)
+#define SALRET_ERROR		(-3)
 
 /*
  * SN_SAL_SET_ERROR_HANDLING_FEATURES bit settings
@@ -827,6 +829,34 @@
 	SAL_CALL_REENTRANT(rv, SN_SAL_IROUTER_OP, SAL_IROUTER_INTR_OFF,
 			   (u64) nasid, (u64) subch, intr, 0, 0, 0);
 	return (int) rv.v0;
+}
+
+/**
+ * ia64_sn_get_fit_compt - read a FIT entry from the PROM header
+ * @nasid: NASID of node to read
+ * @index: FIT entry index to be retrieved (0..n)
+ * @fitentry: 16 byte buffer where FIT entry will be stored.
+ * @banbuf: optional buffer for retrieving banner
+ * @banlen: length of banner buffer
+ *
+ * Access to the physical PROM chips needs to be serialized since reads and
+ * writes can't occur at the same time, so we need to call into the SAL when
+ * we want to look at the FIT entries on the chips.
+ *
+ * Returns:
+ *	%SALRET_OK if ok
+ *	%SALRET_INVALID_ARG if index too big
+ *	%SALRET_NOT_IMPLEMENTED if running on older PROM
+ *	??? if nasid invalid OR banner buffer not large enough
+ */
+static inline int
+ia64_sn_get_fit_compt(u64 nasid, u64 index, void *fitentry, void *banbuf,
+		      u64 banlen)
+{
+	struct ia64_sal_retval rv;
+	SAL_CALL_NOLOCK(rv, SN_SAL_GET_FIT_COMPT, nasid, index, fitentry,
+			banbuf, banlen, 0, 0);
+	return (int) rv.status;
 }
 
 /*

--Boundary-00=_+4dWBEG8gLO4F8W--
