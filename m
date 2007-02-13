From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 13 Feb 2007 00:27:10 +0000
Subject: [PATCH] fsys_getcpu for IA64
Message-Id: <20070213002710.GA1454@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The attached patch implements fsys_getcpu which is fast system call implementation for getcpu system call. The patch is against linux-2.6.20. It needs to apply getcpu system call patch first. The getcpu system call patch can be found at:
http://www.gelato.unsw.edu.au/archives/linux-ia64/0702/19940.html

On 1.6GHz Montectio Tiger4, the following performance data is measured with kernel built with defconfig which has NUMA configured:

Fastest sys_getcpu: 502 itc counts.
Fastest fsys_getcpu: 28 itc counts.

fsys_getcpu performance is largly impacted by whether data (node_to_cpu_map etc) is in cache. It can take fsys_getcpu up to ~150 itc counts in cold cache case.

Thanks.

-Fenghua

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

--- linux-2.6.git.orig/arch/ia64/kernel/fsys.S	2006-11-29 12:26:02.000000000 -0800
+++ linux-2.6.git/arch/ia64/kernel/fsys.S	2007-02-09 08:55:53.000000000 -0800
@@ -10,6 +10,8 @@
  *			probably broke it along the way... ;-)
  * 13-Jul-04 clameter   Implement fsys_clock_gettime and revise fsys_gettimeofday to make
  *                      it capable of using memory based clocks without falling back to C code.
+ * 08-Feb-07 Fenghua Yu Implement fsys_getcpu.
+ *
  */
 
 #include <asm/asmmacro.h>
@@ -505,6 +507,59 @@ EX(.fail_efault, (p15) st8 [r34]=r3)
 #endif
 END(fsys_rt_sigprocmask)
 
+/*
+ * fsys_getcpu doesn't use the third parameter in this implementation. It reads
+ * current_thread_info()->cpu and corresponding node in cpu_to_node_map.
+ */
+ENTRY(fsys_getcpu)
+	.prologue
+	.altrp b6
+	.body
+	;;
+	add r2=TI_FLAGS+IA64_TASK_SIZE,r16
+	tnat.nz p6,p0 = r32			// guard against NaT argument
+	add r3=TI_CPU+IA64_TASK_SIZE,r16
+	;;
+	ld4 r3=[r3]				// M r3 = thread_info->cpu
+	ld4 r2=[r2]				// M r2 = thread_info->flags
+(p6)    br.cond.spnt.few .fail_einval		// B
+	;;
+	tnat.nz p7,p0 = r33			// I guard against NaT argument
+(p7)    br.cond.spnt.few .fail_einval		// B
+#ifdef CONFIG_NUMA
+	movl r17=cpu_to_node_map
+	;;
+EX(.fail_efault, probe.w.fault r32, 3)		// M This takes 5 cycles
+EX(.fail_efault, probe.w.fault r33, 3)		// M This takes 5 cycles
+	shladd r18=r3,1,r17
+	;;
+	ld2 r20=[r18]				// r20 = cpu_to_node_map[cpu]
+	and r2 = TIF_ALLWORK_MASK,r2
+	;;
+	cmp.ne p8,p0=0,r2
+(p8)	br.spnt.many fsys_fallback_syscall
+	;;
+	;;
+EX(.fail_efault, st4 [r32] = r3)
+EX(.fail_efault, st2 [r33] = r20)
+	mov r8=0
+	;;
+#else
+EX(.fail_efault, probe.w.fault r32, 3)		// M This takes 5 cycles
+EX(.fail_efault, probe.w.fault r33, 3)		// M This takes 5 cycles
+	and r2 = TIF_ALLWORK_MASK,r2
+	;;
+	cmp.ne p8,p0=0,r2
+(p8)	br.spnt.many fsys_fallback_syscall
+	;;
+EX(.fail_efault, st4 [r32] = r3)
+EX(.fail_efault, st2 [r33] = r0)
+	mov r8=0
+	;;
+#endif
+	FSYS_RETURN
+END(fsys_getcpu)
+
 ENTRY(fsys_fallback_syscall)
 	.prologue
 	.altrp b6
@@ -878,6 +933,56 @@ fsyscall_table:
 	data8 0				// timer_delete
 	data8 0				// clock_settime
 	data8 fsys_clock_gettime	// clock_gettime
+	data8 0				// clock_getres		// 1255
+	data8 0				// clock_nanosleep
+	data8 0				// fstatfs64
+	data8 0				// statfs64
+	data8 0				// mbind
+	data8 0				// get_mempolicy	// 1260
+	data8 0				// set_mempolicy
+	data8 0				// mq_open
+	data8 0				// mq_unlink
+	data8 0				// mq_timedsend
+	data8 0				// mq_timedreceive	// 1265
+	data8 0				// mq_notify
+	data8 0				// mq_getsetattr
+	data8 0				// kexec_load
+	data8 0				// vserver
+	data8 0				// waitid		// 1270
+	data8 0				// add_key
+	data8 0				// request_key
+	data8 0				// keyctl
+	data8 0				// ioprio_set
+	data8 0				// ioprio_get		// 1275
+	data8 0				// move_pages
+	data8 0				// inotify_init
+	data8 0				// inotify_add_watch
+	data8 0				// inotify_rm_watch
+	data8 0				// migrate_pages	// 1280
+	data8 0				// openat
+	data8 0				// mkdirat
+	data8 0				// mknodat
+	data8 0				// fchownat
+	data8 0				// futimesat		// 1285
+	data8 0				// newfstatat
+	data8 0				// unlinkat
+	data8 0				// renameat
+	data8 0				// linkat
+	data8 0				// symlinkat		// 1290
+	data8 0				// readlinkat
+	data8 0				// fchmodat
+	data8 0				// faccessat
+	data8 0
+	data8 0							// 1295
+	data8 0				// unshare
+	data8 0				// splice
+	data8 0				// set_robust_list
+	data8 0				// get_robust_list
+	data8 0				// sync_file_range	// 1300
+	data8 0				// tee
+	data8 0				// vmsplice
+	data8 0
+	data8 fsys_getcpu		// getcpu		// 1304
 
 	// fill in zeros for the remaining entries
 	.zero:
--- linux-2.6.git.orig/arch/ia64/kernel/asm-offsets.c	2006-11-29 12:26:02.000000000 -0800
+++ linux-2.6.git/arch/ia64/kernel/asm-offsets.c	2007-02-09 07:20:26.000000000 -0800
@@ -35,6 +35,7 @@ void foo(void)
 	BLANK();
 
 	DEFINE(TI_FLAGS, offsetof(struct thread_info, flags));
+	DEFINE(TI_CPU, offsetof(struct thread_info, cpu));
 	DEFINE(TI_PRE_COUNT, offsetof(struct thread_info, preempt_count));
 
 	BLANK();
