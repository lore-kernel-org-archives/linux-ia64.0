From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 May 2004 10:45:45 +0000
Subject: [PATCH] fix MOD_{INC,DEC}_USE_COUNT use in prominfo
Message-Id: <20040507104545.GA10909@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

set proper proc_entry owner instead.  btw, the file is complete mess and
wants a rewrite at least - if not a rearchitecture for a saner
interface.



--- 1.3/arch/ia64/sn/kernel/sn2/prominfo_proc.c	Wed Feb  4 06:39:51 2004
+++ edited/arch/ia64/sn/kernel/sn2/prominfo_proc.c	Mon May  3 13:38:06 2004
@@ -228,11 +228,9 @@
 {
 	int len = 0;
 
-	MOD_INC_USE_COUNT;
 	/* data holds the pointer to this node's FIT */
 	len = dump_version(page, (unsigned long *)data);
 	len = proc_calc_metrics(page, start, off, count, eof, len);
-	MOD_DEC_USE_COUNT;
 	return len;
 }
 
@@ -242,11 +240,9 @@
 {
 	int len = 0;
 
-	MOD_INC_USE_COUNT;
 	/* data holds the pointer to this node's FIT */
 	len = dump_fit(page, (unsigned long *)data);
 	len = proc_calc_metrics(page, start, off, count, eof, len);
-	MOD_DEC_USE_COUNT;
 
 	return len;
 }
@@ -310,6 +306,7 @@
 prominfo_init(void)
 {
 	struct proc_dir_entry **entp;
+	struct proc_dir_entry *p;
 	cnodeid_t cnodeid;
 	nasid_t nasid;
 	char name[NODE_NAME_LEN];
@@ -333,12 +330,16 @@
 		sprintf(name, "node%d", cnodeid);
 		*entp = proc_mkdir(name, sgi_prominfo_entry);
 		nasid = cnodeid_to_nasid(cnodeid);
-		create_proc_read_entry(
+		p = create_proc_read_entry(
 			"fit", 0, *entp, read_fit_entry,
 			lookup_fit(nasid));
-		create_proc_read_entry(
+		if (p)
+			p->owner = THIS_MODULE;
+		p = create_proc_read_entry(
 			"version", 0, *entp, read_version_entry,
 			lookup_fit(nasid));
+		if (p)
+			p->owner = THIS_MODULE;
 	}
 
 	return 0;
