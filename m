From: Keith Owens <kaos@sgi.com>
Date: Tue, 25 Feb 2003 00:24:35 +0000
Subject: [Linux-ia64] [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805925@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The fr entries in struct sal_processor_static_info are 16 bytes wide
but may not start on a 16 byte boundary in the sal record (it depends
on the size of min_state).  Stop gcc from assuming that the fr entries
are 16 byte aligned.

This was misaligning the fr records within sal_processor_static_info.
In addition, because gcc thought that sal_processor_static_info
contained a 16 byte field, sal_processor_static_info was being forced
to 16 byte alignment within struct err_rec, destroying the mapping of
the sal error record (preceding sal record header is only 40 bytes).

Within sal_log_processor_info, the sal_log_mod_error_info_t entries are
fixed size but have a variable number of entries.  Change the
definition from 16 (max) to 0 entries and add a function to calculate
the address of the processor static info within sal_log_processor_info,
based on what sal actually supplied.  Use that function in
ia64_init_handler() to get the min_state data.

Against 2.4.20-ia64-021210.

Index: 20.5/include/asm-ia64/sal.h
--- 20.5/include/asm-ia64/sal.h Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/47_sal.h 1.1.3.2.3.1.1.1.1.3 644)
+++ 20.5(w)/include/asm-ia64/sal.h Tue, 25 Feb 2003 11:17:04 +1100 kaos (linux-2.4/s/47_sal.h 1.1.3.2.3.1.1.1.1.3 644)
@@ -351,7 +351,7 @@ typedef struct sal_processor_static_info
     u64                     ar[128];
     u64                     rr[8];
     struct ia64_fpreg       fr[128];
-} sal_processor_static_info_t;
+} __attribute__((packed)) sal_processor_static_info_t;
 
 typedef struct sal_log_processor_info
 {
@@ -373,11 +373,11 @@ typedef struct sal_log_processor_info
     u64                         proc_error_map;
     u64                         proc_state_parameter;
     u64                         proc_cr_lid;
-    sal_log_mod_error_info_t    cache_check_info[16];
-    sal_log_mod_error_info_t    tlb_check_info[16];
-    sal_log_mod_error_info_t    bus_check_info[16];
-    sal_log_mod_error_info_t    reg_file_check_info[16];
-    sal_log_mod_error_info_t    ms_check_info[16];
+    sal_log_mod_error_info_t    cache_check_info[0];
+    sal_log_mod_error_info_t    tlb_check_info[0];
+    sal_log_mod_error_info_t    bus_check_info[0];
+    sal_log_mod_error_info_t    reg_file_check_info[0];
+    sal_log_mod_error_info_t    ms_check_info[0];
     struct
     {
         u64 regs[5];
@@ -386,6 +386,23 @@ typedef struct sal_log_processor_info
     sal_processor_static_info_t processor_static_info;
 } sal_log_processor_info_t;
 
+/* Position of processor_static_info within processor_info is variable */
+static inline
+sal_processor_static_info_t *addr_processor_static_info(sal_log_processor_info_t *p)
+{
+	sal_processor_static_info_t *s +	(sal_processor_static_info_t *)(
+		((char *) &(p->processor_static_info)) + 
+		  (p->valid.num_cache_check +
+		   p->valid.num_tlb_check +
+		   p->valid.num_bus_check +
+		   p->valid.num_reg_file_check +
+		   p->valid.num_ms_check
+		  ) * sizeof(sal_log_mod_error_info_t)
+	);
+	return s;
+}
+
 /* platform error log structures */
 
 typedef struct sal_log_mem_dev_err_info
Index: 20.5/arch/ia64/kernel/mca.c
--- 20.5/arch/ia64/kernel/mca.c Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/mca.c Tue, 25 Feb 2003 11:14:08 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
@@ -910,7 +910,7 @@ ia64_init_handler (struct pt_regs *regs)
 	plog_ptr=(ia64_err_rec_t *)IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_INIT);
 	proc_ptr = &plog_ptr->proc_err;
 
-	ia64_process_min_state_save(&proc_ptr->processor_static_info.min_state_area);
+	ia64_process_min_state_save(&(addr_processor_static_info(proc_ptr)->min_state_area));
 
 	/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
 	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);


