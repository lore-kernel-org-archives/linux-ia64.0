From: David Howells <dhowells@redhat.com>
Date: Thu, 11 Apr 2013 13:30:32 +0000
Subject: [PATCH 22/26] ia64: Don't use create_proc_read_entry() [RFC]
Message-Id: <20130411133032.32763.82630.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130411132739.32763.82609.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130411132739.32763.82609.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, viro@ZenIV.linux.org.uk

Don't use create_proc_read_entry() as that is deprecated, but rather use
proc_create_data() and seq_file instead.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Tony Luck <tony.luck@intel.com>
cc: Fenghua Yu <fenghua.yu@intel.com>
cc: linux-ia64@vger.kernel.org
---

 arch/ia64/kernel/palinfo.c              |  502 +++++++++++++++----------------
 arch/ia64/kernel/salinfo.c              |   39 +-
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |  108 +++----
 3 files changed, 301 insertions(+), 348 deletions(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 79521d5..b17129e 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -22,6 +22,7 @@
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/efi.h>
@@ -41,7 +42,7 @@ MODULE_LICENSE("GPL");
 
 #define PALINFO_VERSION "0.5"
 
-typedef int (*palinfo_func_t)(char*);
+typedef int (*palinfo_func_t)(struct seq_file *);
 
 typedef struct {
 	const char		*name;		/* name of the proc entry */
@@ -54,7 +55,7 @@ typedef struct {
  *  A bunch of string array to get pretty printing
  */
 
-static char *cache_types[] = {
+static const char *cache_types[] = {
 	"",			/* not used */
 	"Instruction",
 	"Data",
@@ -122,19 +123,16 @@ static const char *mem_attrib[]={
  *	- a pointer to the end of the buffer
  *
  */
-static char *
-bitvector_process(char *p, u64 vector)
+static void bitvector_process(struct seq_file *m, u64 vector)
 {
 	int i,j;
-	const char *units[]={ "", "K", "M", "G", "T" };
+	static const char *units[]={ "", "K", "M", "G", "T" };
 
 	for (i=0, j=0; i < 64; i++ , j=i/10) {
-		if (vector & 0x1) {
-			p += sprintf(p, "%d%s ", 1 << (i-j*10), units[j]);
-		}
+		if (vector & 0x1)
+			seq_printf(m, "%d%s ", 1 << (i-j*10), units[j]);
 		vector >>= 1;
 	}
-	return p;
 }
 
 /*
@@ -149,8 +147,7 @@ bitvector_process(char *p, u64 vector)
  *	- a pointer to the end of the buffer
  *
  */
-static char *
-bitregister_process(char *p, u64 *reg_info, int max)
+static void bitregister_process(struct seq_file *m, u64 *reg_info, int max)
 {
 	int i, begin, skip = 0;
 	u64 value = reg_info[0];
@@ -163,9 +160,9 @@ bitregister_process(char *p, u64 *reg_info, int max)
 
 		if ((value & 0x1) = 0 && skip = 0) {
 			if (begin  <= i - 2)
-				p += sprintf(p, "%d-%d ", begin, i-1);
+				seq_printf(m, "%d-%d ", begin, i-1);
 			else
-				p += sprintf(p, "%d ", i-1);
+				seq_printf(m, "%d ", i-1);
 			skip  = 1;
 			begin = -1;
 		} else if ((value & 0x1) && skip = 1) {
@@ -176,19 +173,15 @@ bitregister_process(char *p, u64 *reg_info, int max)
 	}
 	if (begin > -1) {
 		if (begin < 127)
-			p += sprintf(p, "%d-127", begin);
+			seq_printf(m, "%d-127", begin);
 		else
-			p += sprintf(p, "127");
+			seq_puts(m, "127");
 	}
-
-	return p;
 }
 
-static int
-power_info(char *page)
+static int power_info(struct seq_file *m)
 {
 	s64 status;
-	char *p = page;
 	u64 halt_info_buffer[8];
 	pal_power_mgmt_info_u_t *halt_info =(pal_power_mgmt_info_u_t *)halt_info_buffer;
 	int i;
@@ -198,26 +191,25 @@ power_info(char *page)
 
 	for (i=0; i < 8 ; i++ ) {
 		if (halt_info[i].pal_power_mgmt_info_s.im = 1) {
-			p += sprintf(p,	"Power level %d:\n"
-				     "\tentry_latency       : %d cycles\n"
-				     "\texit_latency        : %d cycles\n"
-				     "\tpower consumption   : %d mW\n"
-				     "\tCache+TLB coherency : %s\n", i,
-				     halt_info[i].pal_power_mgmt_info_s.entry_latency,
-				     halt_info[i].pal_power_mgmt_info_s.exit_latency,
-				     halt_info[i].pal_power_mgmt_info_s.power_consumption,
-				     halt_info[i].pal_power_mgmt_info_s.co ? "Yes" : "No");
+			seq_printf(m,
+				   "Power level %d:\n"
+				   "\tentry_latency       : %d cycles\n"
+				   "\texit_latency        : %d cycles\n"
+				   "\tpower consumption   : %d mW\n"
+				   "\tCache+TLB coherency : %s\n", i,
+				   halt_info[i].pal_power_mgmt_info_s.entry_latency,
+				   halt_info[i].pal_power_mgmt_info_s.exit_latency,
+				   halt_info[i].pal_power_mgmt_info_s.power_consumption,
+				   halt_info[i].pal_power_mgmt_info_s.co ? "Yes" : "No");
 		} else {
-			p += sprintf(p,"Power level %d: not implemented\n",i);
+			seq_printf(m,"Power level %d: not implemented\n", i);
 		}
 	}
-	return p - page;
+	return 0;
 }
 
-static int
-cache_info(char *page)
+static int cache_info(struct seq_file *m)
 {
-	char *p = page;
 	unsigned long i, levels, unique_caches;
 	pal_cache_config_info_t cci;
 	int j, k;
@@ -228,73 +220,74 @@ cache_info(char *page)
 		return 0;
 	}
 
-	p += sprintf(p, "Cache levels  : %ld\nUnique caches : %ld\n\n", levels, unique_caches);
+	seq_printf(m, "Cache levels  : %ld\nUnique caches : %ld\n\n",
+		   levels, unique_caches);
 
 	for (i=0; i < levels; i++) {
-
 		for (j=2; j >0 ; j--) {
-
 			/* even without unification some level may not be present */
-			if ((status=ia64_pal_cache_config_info(i,j, &cci)) != 0) {
+			if ((status=ia64_pal_cache_config_info(i,j, &cci)) != 0)
 				continue;
-			}
-			p += sprintf(p,
-				     "%s Cache level %lu:\n"
-				     "\tSize           : %u bytes\n"
-				     "\tAttributes     : ",
-				     cache_types[j+cci.pcci_unified], i+1,
-				     cci.pcci_cache_size);
-
-			if (cci.pcci_unified) p += sprintf(p, "Unified ");
-
-			p += sprintf(p, "%s\n", cache_mattrib[cci.pcci_cache_attr]);
-
-			p += sprintf(p,
-				     "\tAssociativity  : %d\n"
-				     "\tLine size      : %d bytes\n"
-				     "\tStride         : %d bytes\n",
-				     cci.pcci_assoc, 1<<cci.pcci_line_size, 1<<cci.pcci_stride);
+
+			seq_printf(m,
+				   "%s Cache level %lu:\n"
+				   "\tSize           : %u bytes\n"
+				   "\tAttributes     : ",
+				   cache_types[j+cci.pcci_unified], i+1,
+				   cci.pcci_cache_size);
+
+			if (cci.pcci_unified)
+				seq_puts(m, "Unified ");
+
+			seq_printf(m, "%s\n", cache_mattrib[cci.pcci_cache_attr]);
+
+			seq_printf(m,
+				   "\tAssociativity  : %d\n"
+				   "\tLine size      : %d bytes\n"
+				   "\tStride         : %d bytes\n",
+				   cci.pcci_assoc,
+				   1<<cci.pcci_line_size,
+				   1<<cci.pcci_stride);
 			if (j = 1)
-				p += sprintf(p, "\tStore latency  : N/A\n");
+				seq_puts(m, "\tStore latency  : N/A\n");
 			else
-				p += sprintf(p, "\tStore latency  : %d cycle(s)\n",
-						cci.pcci_st_latency);
+				seq_printf(m, "\tStore latency  : %d cycle(s)\n",
+					   cci.pcci_st_latency);
 
-			p += sprintf(p,
-				     "\tLoad latency   : %d cycle(s)\n"
-				     "\tStore hints    : ", cci.pcci_ld_latency);
+			seq_printf(m,
+				   "\tLoad latency   : %d cycle(s)\n"
+				   "\tStore hints    : ", cci.pcci_ld_latency);
 
 			for(k=0; k < 8; k++ ) {
 				if ( cci.pcci_st_hints & 0x1)
-					p += sprintf(p, "[%s]", cache_st_hints[k]);
+					seq_printf(m, "[%s]", cache_st_hints[k]);
 				cci.pcci_st_hints >>=1;
 			}
-			p += sprintf(p, "\n\tLoad hints     : ");
+			seq_puts(m, "\n\tLoad hints     : ");
 
 			for(k=0; k < 8; k++ ) {
 				if (cci.pcci_ld_hints & 0x1)
-					p += sprintf(p, "[%s]", cache_ld_hints[k]);
+					seq_printf(m, "[%s]", cache_ld_hints[k]);
 				cci.pcci_ld_hints >>=1;
 			}
-			p += sprintf(p,
-				     "\n\tAlias boundary : %d byte(s)\n"
-				     "\tTag LSB        : %d\n"
-				     "\tTag MSB        : %d\n",
-				     1<<cci.pcci_alias_boundary, cci.pcci_tag_lsb,
-				     cci.pcci_tag_msb);
+			seq_printf(m,
+				   "\n\tAlias boundary : %d byte(s)\n"
+				   "\tTag LSB        : %d\n"
+				   "\tTag MSB        : %d\n",
+				   1<<cci.pcci_alias_boundary, cci.pcci_tag_lsb,
+				   cci.pcci_tag_msb);
 
 			/* when unified, data(j=2) is enough */
-			if (cci.pcci_unified) break;
+			if (cci.pcci_unified)
+				break;
 		}
 	}
-	return p - page;
+	return 0;
 }
 
 
-static int
-vm_info(char *page)
+static int vm_info(struct seq_file *m)
 {
-	char *p = page;
 	u64 tr_pages =0, vw_pages=0, tc_pages;
 	u64 attrib;
 	pal_vm_info_1_u_t vm_info_1;
@@ -309,7 +302,7 @@ vm_info(char *page)
 		printk(KERN_ERR "ia64_pal_vm_summary=%ld\n", status);
 	} else {
 
-		p += sprintf(p,
+		seq_printf(m,
 		     "Physical Address Space         : %d bits\n"
 		     "Virtual Address Space          : %d bits\n"
 		     "Protection Key Registers(PKR)  : %d\n"
@@ -324,49 +317,49 @@ vm_info(char *page)
 		     vm_info_1.pal_vm_info_1_s.hash_tag_id,
 		     vm_info_2.pal_vm_info_2_s.rid_size);
 		if (vm_info_2.pal_vm_info_2_s.max_purges = PAL_MAX_PURGES)
-			p += sprintf(p, "unlimited\n");
+			seq_puts(m, "unlimited\n");
 		else
-			p += sprintf(p, "%d\n",
+			seq_printf(m, "%d\n",
 		     		vm_info_2.pal_vm_info_2_s.max_purges ?
 				vm_info_2.pal_vm_info_2_s.max_purges : 1);
 	}
 
 	if (ia64_pal_mem_attrib(&attrib) = 0) {
-		p += sprintf(p, "Supported memory attributes    : ");
+		seq_puts(m, "Supported memory attributes    : ");
 		sep = "";
 		for (i = 0; i < 8; i++) {
 			if (attrib & (1 << i)) {
-				p += sprintf(p, "%s%s", sep, mem_attrib[i]);
+				seq_printf(m, "%s%s", sep, mem_attrib[i]);
 				sep = ", ";
 			}
 		}
-		p += sprintf(p, "\n");
+		seq_putc(m, '\n');
 	}
 
 	if ((status = ia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=0) {
 		printk(KERN_ERR "ia64_pal_vm_page_size=%ld\n", status);
 	} else {
 
-		p += sprintf(p,
-			     "\nTLB walker                     : %simplemented\n"
-			     "Number of DTR                  : %d\n"
-			     "Number of ITR                  : %d\n"
-			     "TLB insertable page sizes      : ",
-			     vm_info_1.pal_vm_info_1_s.vw ? "" : "not ",
-			     vm_info_1.pal_vm_info_1_s.max_dtr_entry+1,
-			     vm_info_1.pal_vm_info_1_s.max_itr_entry+1);
-
+		seq_printf(m,
+			   "\nTLB walker                     : %simplemented\n"
+			   "Number of DTR                  : %d\n"
+			   "Number of ITR                  : %d\n"
+			   "TLB insertable page sizes      : ",
+			   vm_info_1.pal_vm_info_1_s.vw ? "" : "not ",
+			   vm_info_1.pal_vm_info_1_s.max_dtr_entry+1,
+			   vm_info_1.pal_vm_info_1_s.max_itr_entry+1);
 
-		p = bitvector_process(p, tr_pages);
+		bitvector_process(m, tr_pages);
 
-		p += sprintf(p, "\nTLB purgeable page sizes       : ");
+		seq_puts(m, "\nTLB purgeable page sizes       : ");
 
-		p = bitvector_process(p, vw_pages);
+		bitvector_process(m, vw_pages);
 	}
-	if ((status=ia64_get_ptce(&ptce)) != 0) {
+
+	if ((status = ia64_get_ptce(&ptce)) != 0) {
 		printk(KERN_ERR "ia64_get_ptce=%ld\n", status);
 	} else {
-		p += sprintf(p,
+		seq_printf(m,
 		     "\nPurge base address             : 0x%016lx\n"
 		     "Purge outer loop count         : %d\n"
 		     "Purge inner loop count         : %d\n"
@@ -375,7 +368,7 @@ vm_info(char *page)
 		     ptce.base, ptce.count[0], ptce.count[1],
 		     ptce.stride[0], ptce.stride[1]);
 
-		p += sprintf(p,
+		seq_printf(m,
 		     "TC Levels                      : %d\n"
 		     "Unique TC(s)                   : %d\n",
 		     vm_info_1.pal_vm_info_1_s.num_tc_levels,
@@ -385,13 +378,11 @@ vm_info(char *page)
 			for (j=2; j>0 ; j--) {
 				tc_pages = 0; /* just in case */
 
-
 				/* even without unification, some levels may not be present */
-				if ((status=ia64_pal_vm_info(i,j, &tc_info, &tc_pages)) != 0) {
+				if ((status=ia64_pal_vm_info(i,j, &tc_info, &tc_pages)) != 0)
 					continue;
-				}
 
-				p += sprintf(p,
+				seq_printf(m,
 				     "\n%s Translation Cache Level %d:\n"
 				     "\tHash sets           : %d\n"
 				     "\tAssociativity       : %d\n"
@@ -403,15 +394,15 @@ vm_info(char *page)
 				     tc_info.tc_num_entries);
 
 				if (tc_info.tc_pf)
-					p += sprintf(p, "PreferredPageSizeOptimized ");
+					seq_puts(m, "PreferredPageSizeOptimized ");
 				if (tc_info.tc_unified)
-					p += sprintf(p, "Unified ");
+					seq_puts(m, "Unified ");
 				if (tc_info.tc_reduce_tr)
-					p += sprintf(p, "TCReduction");
+					seq_puts(m, "TCReduction");
 
-				p += sprintf(p, "\n\tSupported page sizes: ");
+				seq_puts(m, "\n\tSupported page sizes: ");
 
-				p = bitvector_process(p, tc_pages);
+				bitvector_process(m, tc_pages);
 
 				/* when unified date (j=2) is enough */
 				if (tc_info.tc_unified)
@@ -419,16 +410,14 @@ vm_info(char *page)
 			}
 		}
 	}
-	p += sprintf(p, "\n");
 
-	return p - page;
+	seq_putc(m, '\n');
+	return 0;
 }
 
 
-static int
-register_info(char *page)
+static int register_info(struct seq_file *m)
 {
-	char *p = page;
 	u64 reg_info[2];
 	u64 info;
 	unsigned long phys_stacked;
@@ -442,35 +431,31 @@ register_info(char *page)
 	};
 
 	for(info=0; info < 4; info++) {
-
-		if (ia64_pal_register_info(info, &reg_info[0], &reg_info[1]) != 0) return 0;
-
-		p += sprintf(p, "%-32s : ", info_type[info]);
-
-		p = bitregister_process(p, reg_info, 128);
-
-		p += sprintf(p, "\n");
+		if (ia64_pal_register_info(info, &reg_info[0], &reg_info[1]) != 0)
+			return 0;
+		seq_printf(m, "%-32s : ", info_type[info]);
+		bitregister_process(m, reg_info, 128);
+		seq_putc(m, '\n');
 	}
 
-	if (ia64_pal_rse_info(&phys_stacked, &hints) = 0) {
+	if (ia64_pal_rse_info(&phys_stacked, &hints) = 0)
+		seq_printf(m,
+			   "RSE stacked physical registers   : %ld\n"
+			   "RSE load/store hints             : %ld (%s)\n",
+			   phys_stacked, hints.ph_data,
+			   hints.ph_data < RSE_HINTS_COUNT ? rse_hints[hints.ph_data]: "(??)");
 
-	p += sprintf(p,
-		     "RSE stacked physical registers   : %ld\n"
-		     "RSE load/store hints             : %ld (%s)\n",
-		     phys_stacked, hints.ph_data,
-		     hints.ph_data < RSE_HINTS_COUNT ? rse_hints[hints.ph_data]: "(??)");
-	}
 	if (ia64_pal_debug_info(&iregs, &dregs))
 		return 0;
 
-	p += sprintf(p,
-		     "Instruction debug register pairs : %ld\n"
-		     "Data debug register pairs        : %ld\n", iregs, dregs);
+	seq_printf(m,
+		   "Instruction debug register pairs : %ld\n"
+		   "Data debug register pairs        : %ld\n", iregs, dregs);
 
-	return p - page;
+	return 0;
 }
 
-static char *proc_features_0[]={		/* Feature set 0 */
+static const char *const proc_features_0[]={		/* Feature set 0 */
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
@@ -502,7 +487,7 @@ static char *proc_features_0[]={		/* Feature set 0 */
 	"Enable BERR promotion"
 };
 
-static char *proc_features_16[]={		/* Feature set 16 */
+static const char *const proc_features_16[]={		/* Feature set 16 */
 	"Disable ETM",
 	"Enable ETM",
 	"Enable MCA on half-way timer",
@@ -522,7 +507,7 @@ static char *proc_features_16[]={		/* Feature set 16 */
 	NULL, NULL, NULL, NULL, NULL
 };
 
-static char **proc_features[]={
+static const char *const *const proc_features[]={
 	proc_features_0,
 	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 	NULL, NULL, NULL, NULL,
@@ -530,11 +515,10 @@ static char **proc_features[]={
 	NULL, NULL, NULL, NULL,
 };
 
-static char * feature_set_info(char *page, u64 avail, u64 status, u64 control,
-							unsigned long set)
+static void feature_set_info(struct seq_file *m, u64 avail, u64 status, u64 control,
+			     unsigned long set)
 {
-	char *p = page;
-	char **vf, **v;
+	const char *const *vf, *const *v;
 	int i;
 
 	vf = v = proc_features[set];
@@ -547,13 +531,13 @@ static char * feature_set_info(char *page, u64 avail, u64 status, u64 control,
 		if (vf)
 			v = vf + i;
 		if ( v && *v ) {
-			p += sprintf(p, "%-40s : %s %s\n", *v,
+			seq_printf(m, "%-40s : %s %s\n", *v,
 				avail & 0x1 ? (status & 0x1 ?
-						"On " : "Off"): "",
+					      "On " : "Off"): "",
 				avail & 0x1 ? (control & 0x1 ?
 						"Ctrl" : "NoCtrl"): "");
 		} else {
-			p += sprintf(p, "Feature set %2ld bit %2d\t\t\t"
+			seq_printf(m, "Feature set %2ld bit %2d\t\t\t"
 					" : %s %s\n",
 				set, i,
 				avail & 0x1 ? (status & 0x1 ?
@@ -562,36 +546,32 @@ static char * feature_set_info(char *page, u64 avail, u64 status, u64 control,
 						"Ctrl" : "NoCtrl"): "");
 		}
 	}
-	return p;
 }
 
-static int
-processor_info(char *page)
+static int processor_info(struct seq_file *m)
 {
-	char *p = page;
 	u64 avail=1, status=1, control=1, feature_set=0;
 	s64 ret;
 
 	do {
 		ret = ia64_pal_proc_get_features(&avail, &status, &control,
 						feature_set);
-		if (ret < 0) {
-			return p - page;
-		}
+		if (ret < 0)
+			return 0;
+
 		if (ret = 1) {
 			feature_set++;
 			continue;
 		}
 
-		p = feature_set_info(p, avail, status, control, feature_set);
-
+		feature_set_info(m, avail, status, control, feature_set);
 		feature_set++;
 	} while(1);
 
-	return p - page;
+	return 0;
 }
 
-static const char *bus_features[]={
+static const char *const bus_features[]={
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
@@ -617,125 +597,118 @@ static const char *bus_features[]={
 };
 
 
-static int
-bus_info(char *page)
+static int bus_info(struct seq_file *m)
 {
-	char *p = page;
-	const char **v = bus_features;
+	const char *const *v = bus_features;
 	pal_bus_features_u_t av, st, ct;
 	u64 avail, status, control;
 	int i;
 	s64 ret;
 
-	if ((ret=ia64_pal_bus_get_features(&av, &st, &ct)) != 0) return 0;
+	if ((ret=ia64_pal_bus_get_features(&av, &st, &ct)) != 0)
+		return 0;
 
 	avail   = av.pal_bus_features_val;
 	status  = st.pal_bus_features_val;
 	control = ct.pal_bus_features_val;
 
 	for(i=0; i < 64; i++, v++, avail >>=1, status >>=1, control >>=1) {
-		if ( ! *v ) continue;
-		p += sprintf(p, "%-48s : %s%s %s\n", *v,
-				avail & 0x1 ? "" : "NotImpl",
-				avail & 0x1 ? (status  & 0x1 ? "On" : "Off"): "",
-				avail & 0x1 ? (control & 0x1 ? "Ctrl" : "NoCtrl"): "");
+		if ( ! *v )
+			continue;
+		seq_printf(m, "%-48s : %s%s %s\n", *v,
+			   avail & 0x1 ? "" : "NotImpl",
+			   avail & 0x1 ? (status  & 0x1 ? "On" : "Off"): "",
+			   avail & 0x1 ? (control & 0x1 ? "Ctrl" : "NoCtrl"): "");
 	}
-	return p - page;
+	return 0;
 }
 
-static int
-version_info(char *page)
+static int version_info(struct seq_file *m)
 {
 	pal_version_u_t min_ver, cur_ver;
-	char *p = page;
 
 	if (ia64_pal_version(&min_ver, &cur_ver) != 0)
 		return 0;
 
-	p += sprintf(p,
-		     "PAL_vendor : 0x%02x (min=0x%02x)\n"
-		     "PAL_A      : %02x.%02x (min=%02x.%02x)\n"
-		     "PAL_B      : %02x.%02x (min=%02x.%02x)\n",
-		     cur_ver.pal_version_s.pv_pal_vendor,
-		     min_ver.pal_version_s.pv_pal_vendor,
-		     cur_ver.pal_version_s.pv_pal_a_model,
-		     cur_ver.pal_version_s.pv_pal_a_rev,
-		     min_ver.pal_version_s.pv_pal_a_model,
-		     min_ver.pal_version_s.pv_pal_a_rev,
-		     cur_ver.pal_version_s.pv_pal_b_model,
-		     cur_ver.pal_version_s.pv_pal_b_rev,
-		     min_ver.pal_version_s.pv_pal_b_model,
-		     min_ver.pal_version_s.pv_pal_b_rev);
-	return p - page;
+	seq_printf(m,
+		   "PAL_vendor : 0x%02x (min=0x%02x)\n"
+		   "PAL_A      : %02x.%02x (min=%02x.%02x)\n"
+		   "PAL_B      : %02x.%02x (min=%02x.%02x)\n",
+		   cur_ver.pal_version_s.pv_pal_vendor,
+		   min_ver.pal_version_s.pv_pal_vendor,
+		   cur_ver.pal_version_s.pv_pal_a_model,
+		   cur_ver.pal_version_s.pv_pal_a_rev,
+		   min_ver.pal_version_s.pv_pal_a_model,
+		   min_ver.pal_version_s.pv_pal_a_rev,
+		   cur_ver.pal_version_s.pv_pal_b_model,
+		   cur_ver.pal_version_s.pv_pal_b_rev,
+		   min_ver.pal_version_s.pv_pal_b_model,
+		   min_ver.pal_version_s.pv_pal_b_rev);
+	return 0;
 }
 
-static int
-perfmon_info(char *page)
+static int perfmon_info(struct seq_file *m)
 {
-	char *p = page;
 	u64 pm_buffer[16];
 	pal_perf_mon_info_u_t pm_info;
 
-	if (ia64_pal_perf_mon_info(pm_buffer, &pm_info) != 0) return 0;
-
-	p += sprintf(p,
-		     "PMC/PMD pairs                 : %d\n"
-		     "Counter width                 : %d bits\n"
-		     "Cycle event number            : %d\n"
-		     "Retired event number          : %d\n"
-		     "Implemented PMC               : ",
-		     pm_info.pal_perf_mon_info_s.generic, pm_info.pal_perf_mon_info_s.width,
-		     pm_info.pal_perf_mon_info_s.cycles, pm_info.pal_perf_mon_info_s.retired);
+	if (ia64_pal_perf_mon_info(pm_buffer, &pm_info) != 0)
+		return 0;
 
-	p = bitregister_process(p, pm_buffer, 256);
-	p += sprintf(p, "\nImplemented PMD               : ");
-	p = bitregister_process(p, pm_buffer+4, 256);
-	p += sprintf(p, "\nCycles count capable          : ");
-	p = bitregister_process(p, pm_buffer+8, 256);
-	p += sprintf(p, "\nRetired bundles count capable : ");
+	seq_printf(m,
+		   "PMC/PMD pairs                 : %d\n"
+		   "Counter width                 : %d bits\n"
+		   "Cycle event number            : %d\n"
+		   "Retired event number          : %d\n"
+		   "Implemented PMC               : ",
+		   pm_info.pal_perf_mon_info_s.generic,
+		   pm_info.pal_perf_mon_info_s.width,
+		   pm_info.pal_perf_mon_info_s.cycles,
+		   pm_info.pal_perf_mon_info_s.retired);
+
+	bitregister_process(m, pm_buffer, 256);
+	seq_puts(m, "\nImplemented PMD               : ");
+	bitregister_process(m, pm_buffer+4, 256);
+	seq_puts(m, "\nCycles count capable          : ");
+	bitregister_process(m, pm_buffer+8, 256);
+	seq_puts(m, "\nRetired bundles count capable : ");
 
 #ifdef CONFIG_ITANIUM
 	/*
 	 * PAL_PERF_MON_INFO reports that only PMC4 can be used to count CPU_CYCLES
 	 * which is wrong, both PMC4 and PMD5 support it.
 	 */
-	if (pm_buffer[12] = 0x10) pm_buffer[12]=0x30;
+	if (pm_buffer[12] = 0x10)
+		pm_buffer[12]=0x30;
 #endif
 
-	p = bitregister_process(p, pm_buffer+12, 256);
-
-	p += sprintf(p, "\n");
-
-	return p - page;
+	bitregister_process(m, pm_buffer+12, 256);
+	seq_putc(m, '\n');
+	return 0;
 }
 
-static int
-frequency_info(char *page)
+static int frequency_info(struct seq_file *m)
 {
-	char *p = page;
 	struct pal_freq_ratio proc, itc, bus;
 	unsigned long base;
 
 	if (ia64_pal_freq_base(&base) = -1)
-		p += sprintf(p, "Output clock            : not implemented\n");
+		seq_puts(m, "Output clock            : not implemented\n");
 	else
-		p += sprintf(p, "Output clock            : %ld ticks/s\n", base);
+		seq_printf(m, "Output clock            : %ld ticks/s\n", base);
 
 	if (ia64_pal_freq_ratios(&proc, &bus, &itc) != 0) return 0;
 
-	p += sprintf(p,
+	seq_printf(m,
 		     "Processor/Clock ratio   : %d/%d\n"
 		     "Bus/Clock ratio         : %d/%d\n"
 		     "ITC/Clock ratio         : %d/%d\n",
 		     proc.num, proc.den, bus.num, bus.den, itc.num, itc.den);
-
-	return p - page;
+	return 0;
 }
 
-static int
-tr_info(char *page)
+static int tr_info(struct seq_file *m)
 {
-	char *p = page;
 	long status;
 	pal_tr_valid_u_t tr_valid;
 	u64 tr_buffer[4];
@@ -794,39 +767,40 @@ tr_info(char *page)
 
 		ifa_reg  = (struct ifa_reg *)&tr_buffer[2];
 
-		if (ifa_reg->valid = 0) continue;
+		if (ifa_reg->valid = 0)
+			continue;
 
 		gr_reg   = (struct gr_reg *)tr_buffer;
 		itir_reg = (struct itir_reg *)&tr_buffer[1];
 		rid_reg  = (struct rid_reg *)&tr_buffer[3];
 
 		pgm	 = -1 << (itir_reg->ps - 12);
-		p += sprintf(p,
-			     "%cTR%lu: av=%d pv=%d dv=%d mv=%d\n"
-			     "\tppn  : 0x%lx\n"
-			     "\tvpn  : 0x%lx\n"
-			     "\tps   : ",
-			     "ID"[i], j,
-			     tr_valid.pal_tr_valid_s.access_rights_valid,
-			     tr_valid.pal_tr_valid_s.priv_level_valid,
-			     tr_valid.pal_tr_valid_s.dirty_bit_valid,
-			     tr_valid.pal_tr_valid_s.mem_attr_valid,
-			     (gr_reg->ppn & pgm)<< 12, (ifa_reg->vpn & pgm)<< 12);
-
-		p = bitvector_process(p, 1<< itir_reg->ps);
-
-		p += sprintf(p,
-			     "\n\tpl   : %d\n"
-			     "\tar   : %d\n"
-			     "\trid  : %x\n"
-			     "\tp    : %d\n"
-			     "\tma   : %d\n"
-			     "\td    : %d\n",
-			     gr_reg->pl, gr_reg->ar, rid_reg->rid, gr_reg->p, gr_reg->ma,
-			     gr_reg->d);
+		seq_printf(m,
+			   "%cTR%lu: av=%d pv=%d dv=%d mv=%d\n"
+			   "\tppn  : 0x%lx\n"
+			   "\tvpn  : 0x%lx\n"
+			   "\tps   : ",
+			   "ID"[i], j,
+			   tr_valid.pal_tr_valid_s.access_rights_valid,
+			   tr_valid.pal_tr_valid_s.priv_level_valid,
+			   tr_valid.pal_tr_valid_s.dirty_bit_valid,
+			   tr_valid.pal_tr_valid_s.mem_attr_valid,
+			   (gr_reg->ppn & pgm)<< 12, (ifa_reg->vpn & pgm)<< 12);
+
+		bitvector_process(m, 1<< itir_reg->ps);
+
+		seq_printf(m,
+			   "\n\tpl   : %d\n"
+			   "\tar   : %d\n"
+			   "\trid  : %x\n"
+			   "\tp    : %d\n"
+			   "\tma   : %d\n"
+			   "\td    : %d\n",
+			   gr_reg->pl, gr_reg->ar, rid_reg->rid, gr_reg->p, gr_reg->ma,
+			   gr_reg->d);
 		}
 	}
-	return p - page;
+	return 0;
 }
 
 
@@ -834,7 +808,7 @@ tr_info(char *page)
 /*
  * List {name,function} pairs for every entry in /proc/palinfo/cpu*
  */
-static palinfo_entry_t palinfo_entries[]={
+static const palinfo_entry_t palinfo_entries[]={
 	{ "version_info",	version_info, },
 	{ "vm_info",		vm_info, },
 	{ "cache_info",		cache_info, },
@@ -876,7 +850,7 @@ typedef union {
  */
 typedef struct {
 	palinfo_func_t	func;	/* pointer to function to call */
-	char		*page;	/* buffer to store results */
+	struct seq_file *m;	/* buffer to store results */
 	int		ret;	/* return value from call */
 } palinfo_smp_data_t;
 
@@ -889,7 +863,7 @@ static void
 palinfo_smp_call(void *info)
 {
 	palinfo_smp_data_t *data = (palinfo_smp_data_t *)info;
-	data->ret = (*data->func)(data->page);
+	data->ret = (*data->func)(data->m);
 }
 
 /*
@@ -899,13 +873,13 @@ palinfo_smp_call(void *info)
  *	otherwise how many bytes in the "page" buffer were written
  */
 static
-int palinfo_handle_smp(pal_func_cpu_u_t *f, char *page)
+int palinfo_handle_smp(struct seq_file *m, pal_func_cpu_u_t *f)
 {
 	palinfo_smp_data_t ptr;
 	int ret;
 
 	ptr.func = palinfo_entries[f->func_id].proc_read;
-	ptr.page = page;
+	ptr.m = m;
 	ptr.ret  = 0; /* just in case */
 
 
@@ -919,7 +893,7 @@ int palinfo_handle_smp(pal_func_cpu_u_t *f, char *page)
 }
 #else /* ! CONFIG_SMP */
 static
-int palinfo_handle_smp(pal_func_cpu_u_t *f, char *page)
+int palinfo_handle_smp(struct seq_file *m, pal_func_cpu_u_t *f)
 {
 	printk(KERN_ERR "palinfo: should not be called with non SMP kernel\n");
 	return 0;
@@ -929,34 +903,35 @@ int palinfo_handle_smp(pal_func_cpu_u_t *f, char *page)
 /*
  * Entry point routine: all calls go through this function
  */
-static int
-palinfo_read_entry(char *page, char **start, off_t off, int count, int *eof, void *data)
+static int proc_palinfo_show(struct seq_file *m, void *v)
 {
-	int len=0;
-	pal_func_cpu_u_t *f = (pal_func_cpu_u_t *)&data;
+	pal_func_cpu_u_t *f = (pal_func_cpu_u_t *)&m->private;
 
 	/*
 	 * in SMP mode, we may need to call another CPU to get correct
 	 * information. PAL, by definition, is processor specific
 	 */
 	if (f->req_cpu = get_cpu())
-		len = (*palinfo_entries[f->func_id].proc_read)(page);
+		(*palinfo_entries[f->func_id].proc_read)(m);
 	else
-		len = palinfo_handle_smp(f, page);
+		palinfo_handle_smp(m, f);
 
 	put_cpu();
+	return 0;
+}
 
-	if (len <= off+count) *eof = 1;
-
-	*start = page + off;
-	len   -= off;
-
-	if (len>count) len = count;
-	if (len<0) len = 0;
-
-	return len;
+static int proc_palinfo_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, proc_palinfo_show, PDE_DATA(inode));
 }
 
+static const struct file_operations proc_palinfo_fops = {
+	.open		= proc_palinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static void __cpuinit
 create_palinfo_proc_entries(unsigned int cpu)
 {
@@ -974,9 +949,8 @@ create_palinfo_proc_entries(unsigned int cpu)
 
 	for (j=0; j < NR_PALINFO_ENTRIES; j++) {
 		f.func_id = j;
-		create_proc_read_entry(
-			palinfo_entries[j].name, 0, cpu_dir,
-			palinfo_read_entry, (void *)f.value);
+		proc_create_data(palinfo_entries[j].name, 0, cpu_dir,
+				 &proc_palinfo_fops, (void *)f.value);
 	}
 }
 
diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index a97d75b..5035245 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -40,6 +40,7 @@
 #include <linux/cpu.h>
 #include <linux/types.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/timer.h>
@@ -53,7 +54,7 @@ MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
 MODULE_LICENSE("GPL");
 
-static int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);
+static const struct file_operations proc_salinfo_fops;
 
 typedef struct {
 	const char		*name;		/* name of the proc entry */
@@ -65,7 +66,7 @@ typedef struct {
  * List {name,feature} pairs for every entry in /proc/sal/<feature>
  * that this module exports
  */
-static salinfo_entry_t salinfo_entries[]={
+static const salinfo_entry_t salinfo_entries[]={
 	{ "bus_lock",           IA64_SAL_PLATFORM_FEATURE_BUS_LOCK, },
 	{ "irq_redirection",	IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT, },
 	{ "ipi_redirection",	IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT, },
@@ -629,8 +630,9 @@ salinfo_init(void)
 
 	for (i=0; i < NR_SALINFO_ENTRIES; i++) {
 		/* pass the feature bit in question as misc data */
-		*sdir++ = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
-						  salinfo_read, (void *)salinfo_entries[i].feature);
+		*sdir++ = proc_create_data(salinfo_entries[i].name, 0, salinfo_dir,
+					   &proc_salinfo_fops,
+					   (void *)salinfo_entries[i].feature);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
@@ -676,22 +678,23 @@ salinfo_init(void)
  * 'data' contains an integer that corresponds to the feature we're
  * testing
  */
-static int
-salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data)
+static int proc_salinfo_show(struct seq_file *m, void *v)
 {
-	int len = 0;
-
-	len = sprintf(page, (sal_platform_features & (unsigned long)data) ? "1\n" : "0\n");
-
-	if (len <= off+count) *eof = 1;
-
-	*start = page + off;
-	len   -= off;
-
-	if (len>count) len = count;
-	if (len<0) len = 0;
+	unsigned long data = (unsigned long)v;
+	seq_puts(m, (sal_platform_features & data) ? "1\n" : "0\n");
+	return 0;
+}
 
-	return len;
+static int proc_salinfo_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, proc_salinfo_show, PDE_DATA(inode));
 }
 
+static const struct file_operations proc_salinfo_fops = {
+	.open		= proc_salinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 module_init(salinfo_init);
diff --git a/arch/ia64/sn/kernel/sn2/prominfo_proc.c b/arch/ia64/sn/kernel/sn2/prominfo_proc.c
index 90298bd..daa8d6b 100644
--- a/arch/ia64/sn/kernel/sn2/prominfo_proc.c
+++ b/arch/ia64/sn/kernel/sn2/prominfo_proc.c
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/nodemask.h>
 #include <asm/io.h>
 #include <asm/sn/sn_sal.h>
@@ -101,18 +102,18 @@ get_fit_entry(unsigned long nasid, int index, unsigned long *fentry,
 /*
  * These two routines display the FIT table for each node.
  */
-static int dump_fit_entry(char *page, unsigned long *fentry)
+static void dump_fit_entry(struct seq_file *m, unsigned long *fentry)
 {
 	unsigned type;
 
 	type = FIT_TYPE(fentry[1]);
-	return sprintf(page, "%02x %-25s %x.%02x %016lx %u\n",
-		       type,
-		       fit_type_name(type),
-		       FIT_MAJOR(fentry[1]), FIT_MINOR(fentry[1]),
-		       fentry[0],
-		       /* mult by sixteen to get size in bytes */
-		       (unsigned)(fentry[1] & 0xffffff) * 16);
+	seq_printf(m, "%02x %-25s %x.%02x %016lx %u\n",
+		   type,
+		   fit_type_name(type),
+		   FIT_MAJOR(fentry[1]), FIT_MINOR(fentry[1]),
+		   fentry[0],
+		   /* mult by sixteen to get size in bytes */
+		   (unsigned)(fentry[1] & 0xffffff) * 16);
 }
 
 
@@ -124,31 +125,39 @@ static int dump_fit_entry(char *page, unsigned long *fentry)
  * OK except for 4kB pages (and no one is going to do that on SN
  * anyway).
  */
-static int
-dump_fit(char *page, unsigned long nasid)
+static int proc_fit_show(struct seq_file *m, void *v)
 {
+	unsigned long nasid = (unsigned long)m->private;
 	unsigned long fentry[2];
 	int index;
-	char *p;
 
-	p = page;
 	for (index=0;;index++) {
 		BUG_ON(index * 60 > PAGE_SIZE);
 		if (get_fit_entry(nasid, index, fentry, NULL, 0))
 			break;
-		p += dump_fit_entry(p, fentry);
+		dump_fit_entry(m, fentry);
 	}
+	return 0;
+}
 
-	return p - page;
+static int proc_fit_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, proc_fit_show, PDE_DATA(inode));
 }
 
-static int
-dump_version(char *page, unsigned long nasid)
+static const struct file_operations proc_fit_fops = {
+	.open		= proc_fit_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int proc_version_show(struct seq_file *m, void *v)
 {
+	unsigned long nasid = (unsigned long)m->private;
 	unsigned long fentry[2];
 	char banner[128];
 	int index;
-	int len;
 
 	for (index = 0; ; index++) {
 		if (get_fit_entry(nasid, index, fentry, banner,
@@ -158,56 +167,24 @@ dump_version(char *page, unsigned long nasid)
 			break;
 	}
 
-	len = sprintf(page, "%x.%02x\n", FIT_MAJOR(fentry[1]),
-		      FIT_MINOR(fentry[1]));
-	page += len;
+	seq_printf(m, "%x.%02x\n", FIT_MAJOR(fentry[1]), FIT_MINOR(fentry[1]));
 
 	if (banner[0])
-		len += snprintf(page, PAGE_SIZE-len, "%s\n", banner);
-
-	return len;
-}
-
-/* same as in proc_misc.c */
-static int
-proc_calc_metrics(char *page, char **start, off_t off, int count, int *eof,
-		  int len)
-{
-	if (len <= off + count)
-		*eof = 1;
-	*start = page + off;
-	len -= off;
-	if (len > count)
-		len = count;
-	if (len < 0)
-		len = 0;
-	return len;
+		seq_printf(m, "%s\n", banner);
+	return 0;
 }
 
-static int
-read_version_entry(char *page, char **start, off_t off, int count, int *eof,
-		   void *data)
+static int proc_version_open(struct inode *inode, struct file *file)
 {
-	int len;
-
-	/* data holds the NASID of the node */
-	len = dump_version(page, (unsigned long)data);
-	len = proc_calc_metrics(page, start, off, count, eof, len);
-	return len;
+	return single_open(file, proc_version_show, PDE_DATA(inode));
 }
 
-static int
-read_fit_entry(char *page, char **start, off_t off, int count, int *eof,
-	       void *data)
-{
-	int len;
-
-	/* data holds the NASID of the node */
-	len = dump_fit(page, (unsigned long)data);
-	len = proc_calc_metrics(page, start, off, count, eof, len);
-
-	return len;
-}
+static const struct file_operations proc_version_fops = {
+	.open		= proc_version_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 
 /* module entry points */
 int __init prominfo_init(void);
@@ -216,12 +193,11 @@ void __exit prominfo_exit(void);
 module_init(prominfo_init);
 module_exit(prominfo_exit);
 
-static struct proc_dir_entry *sgi_prominfo_entry;
-
 #define NODE_NAME_LEN 11
 
 int __init prominfo_init(void)
 {
+	struct proc_dir_entry *sgi_prominfo_entry;
 	cnodeid_t cnodeid;
 
 	if (!ia64_platform_is("sn2"))
@@ -241,10 +217,10 @@ int __init prominfo_init(void)
 		if (!dir)
 			continue;
 		nasid = cnodeid_to_nasid(cnodeid);
-		create_proc_read_entry("fit", 0, dir, read_fit_entry,
-					   (void *)nasid);
-		create_proc_read_entry("version", 0, dir,
-					   read_version_entry, (void *)nasid);
+		proc_create_data("fit", 0, dir,
+				 &proc_fit_fops, (void *)nasid);
+		proc_create_data("version", 0, dir,
+				 &proc_version_fops, (void *)nasid);
 	}
 	return 0;
 }

