From: Keith Owens <kaos@sgi.com>
Date: Sat, 22 Mar 2003 15:43:30 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20 ia64_sal_mc_rendez must not lock
Message-Id: <marc-linux-ia64-105590723705292@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705290@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705290@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 22 Mar 2003 13:03:57 +0000, 
Matthew Wilcox <willy@debian.org> wrote:
>Maybe this is (in part) what's causing
>https://lists.linuxia64.org/archives/linux-ia64/2002-August/003876.html
>
>Apparently the reason it hangs is that I leave my console at the default
>9600 baud (you know, like a customer would ..) and when dumping state
>it takes so long that the system assumes the CPU has hung.  Bag o' shite.

I doubt that your hang has anything to do with MCA rendezvous code,
rendezvous and timeouts are not done at boot time.  Also my testing
with SGI SAL shows that the rendezvous cpus are driven first, only
after they all rendezvous or timeout is the monarch cpu passed the MCA.

More likely you are hitting the mismatch between the SAL record format
(which is variable length and has misaligned fields) and the C
definitions for those records.  In theory, that can cause an oops while
processing the record.

Try this extract from kdb v4.0.  Patch is against 2.4.20-ia64-021210,
it should be in the latest ia64 (bk) trees.  I did the original patch,
David Mosberger rewrote it.

Index: 20.5/include/asm-ia64/sal.h
--- 20.5/include/asm-ia64/sal.h Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/47_sal.h 1.1.3.2.3.1.1.1.1.3 644)
+++ 20.5(w)/include/asm-ia64/sal.h Sun, 23 Mar 2003 02:39:23 +1100 kaos (linux-2.4/s/47_sal.h 1.1.3.2.3.1.1.1.1.3 644)
@@ -353,6 +353,11 @@ typedef struct sal_processor_static_info
     struct ia64_fpreg       fr[128];
 } sal_processor_static_info_t;
 
+struct sal_cpuid_info {
+	u64 regs[5];
+	u64 reserved;
+};
+
 typedef struct sal_log_processor_info
 {
     sal_log_section_hdr_t       header;
@@ -373,19 +378,34 @@ typedef struct sal_log_processor_info
     u64                         proc_error_map;
     u64                         proc_state_parameter;
     u64                         proc_cr_lid;
-    sal_log_mod_error_info_t    cache_check_info[16];
-    sal_log_mod_error_info_t    tlb_check_info[16];
-    sal_log_mod_error_info_t    bus_check_info[16];
-    sal_log_mod_error_info_t    reg_file_check_info[16];
-    sal_log_mod_error_info_t    ms_check_info[16];
-    struct
-    {
-        u64 regs[5];
-        u64 reserved;
-    } cpuid_info;
-    sal_processor_static_info_t processor_static_info;
+	/*
+	 * The rest of this structure consists of variable-length arrays, which can't be
+	 * expressed in C.
+	 */
+	sal_log_mod_error_info_t info[0];
+	/*
+	 * This is what the rest looked like if C supported variable-length arrays:
+	 *
+	 * sal_log_mod_error_info_t cache_check_info[.valid.num_cache_check];
+	 * sal_log_mod_error_info_t tlb_check_info[.valid.num_tlb_check];
+	 * sal_log_mod_error_info_t bus_check_info[.valid.num_bus_check];
+	 * sal_log_mod_error_info_t reg_file_check_info[.valid.num_reg_file_check];
+	 * sal_log_mod_error_info_t ms_check_info[.valid.num_ms_check];
+	 * struct sal_cpuid_info cpuid_info;
+	 * sal_processor_static_info_t processor_static_info;
+	 */
 } sal_log_processor_info_t;
 
+/* Given a sal_log_processor_info_t pointer, return a pointer to the processor_static_info: */
+#define SAL_LPI_PSI_INFO(l)								\
+({	sal_log_processor_info_t *_l = (l);						\
+	((sal_processor_static_info_t *)						\
+	 ((char *) _l->info + ((_l->valid.num_cache_check + _l->valid.num_tlb_check	\
+			  + _l->valid.num_bus_check + _l->valid.num_reg_file_check	\
+			  + _l->valid.num_ms_check) * sizeof(sal_log_mod_error_info_t)	\
+			 + sizeof(struct sal_cpuid_info))));				\
+})
+
 /* platform error log structures */
 
 typedef struct sal_log_mem_dev_err_info
Index: 20.5/arch/ia64/kernel/mca.c
--- 20.5/arch/ia64/kernel/mca.c Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/mca.c Sun, 23 Mar 2003 02:38:05 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
@@ -910,7 +910,7 @@ ia64_init_handler (struct pt_regs *regs)
 	plog_ptr=(ia64_err_rec_t *)IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_INIT);
 	proc_ptr = &plog_ptr->proc_err;
 
-	ia64_process_min_state_save(&proc_ptr->processor_static_info.min_state_area);
+	ia64_process_min_state_save(&SAL_LPI_PSI_INFO(proc_ptr)->min_state_area);
 
 	/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
 	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
@@ -1704,7 +1704,7 @@ ia64_log_proc_dev_err_info_print (sal_lo
 	 *  absent. Also, current implementations only allocate space for number of
 	 *  elements used.  So we walk the data pointer from here on.
 	 */
-	p_data = &slpi->cache_check_info[0];
+	p_data = &slpi->info[0];
 
 	/* Print the cache check information if any*/
 	for (i = 0 ; i < slpi->valid.num_cache_check; i++, p_data++)


