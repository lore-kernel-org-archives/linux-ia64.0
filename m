From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 24 Dec 2003 00:50:53 +0000
Subject: Re: Request to add IA32 syscall 270 (tgkill)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080902090407000505030208"
Message-Id: <marc-linux-ia64-107222724124257@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107208457911976@msgid-missing>
In-Reply-To: <marc-linux-ia64-107208457911976@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080902090407000505030208
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

On 12/22/2003 01:08 AM, Carlos O'Donell wrote:
> linux-ia64,
> 
> Running 2.6.0 from linux-ia64-2.5 bk tree,
> 
> "IA32 syscall #270 issued, maybe we should implement it"
> 
> Would anyone be kind enough to add tgkill (#270) to the IA32 
> syscall emulation? sys_tgkill looks safe enough (3 int parameters)
> that it doesn't need a 32-bit wrapper?
> 

Please try the attached patches. These patches add the missing ia32 syscalls to 2.6.

	-Arun


--------------080902090407000505030208
Content-Type: text/plain;
 name="mi.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mi.patch"

Index: linux-2.6/fs/compat.c
===================================================================
--- linux-2.6/fs/compat.c	(revision 23)
+++ linux-2.6/fs/compat.c	(working copy)
@@ -554,3 +554,104 @@
 	return compat_sys_fcntl64(fd, cmd, arg);
 }
 
+extern asmlinkage long sys_io_setup(unsigned nr_reqs, aio_context_t *ctx);
+
+asmlinkage long compat_sys_io_setup(unsigned nr_reqs, u32 *ctx32p)
+{
+	long ret;
+	aio_context_t ctx64;
+	compat_uptr_t uptr;
+
+	mm_segment_t oldfs = get_fs();
+	if (unlikely(get_user(uptr, ctx32p)))
+		return -EFAULT;
+
+	ctx64 = (aio_context_t) compat_ptr(uptr);
+	set_fs(KERNEL_DS);
+	ret = sys_io_setup(nr_reqs, &ctx64);
+	set_fs(oldfs);
+	/* truncating is ok because it's a user address */
+	if (!ret)
+		ret = put_user((u32) ctx64, ctx32p);
+	return ret;
+}
+
+extern asmlinkage long sys_io_getevents(aio_context_t ctx_id,
+					  long min_nr,
+					  long nr,
+					  struct io_event *events,
+					  struct timespec *timeout);
+
+asmlinkage long compat_sys_io_getevents(aio_context_t ctx_id,
+				 unsigned long min_nr,
+				 unsigned long nr,
+				 struct io_event *events,
+				 struct compat_timespec *timeout)
+{
+	long ret;
+	struct timespec t;
+	struct timespec *ut = NULL;
+
+	ret = -EFAULT;
+	if (unlikely(!access_ok(VERIFY_WRITE, events, 
+				nr * sizeof(struct io_event))))
+		goto out;
+	if (timeout) {
+		if (get_compat_timespec(&t, timeout))
+			goto out;
+
+		ut = compat_alloc_user_space(sizeof(*ut));
+		if (copy_to_user(ut, &t, sizeof(t)) )
+			goto out;
+	} 
+	ret = sys_io_getevents(ctx_id, min_nr, nr, events, ut);
+	if (!ret && timeout && put_compat_timespec(&t, timeout))
+		return -EFAULT;
+out:
+	return ret;
+}
+
+extern asmlinkage long sys_io_submit(aio_context_t, long, 
+				struct iocb __user **);
+
+static inline long
+copy_iocb(long nr, u32 *ptr32, u64 *ptr64)
+{
+	compat_uptr_t uptr;
+	long ret;
+	int i;
+
+	ret = -EFAULT;
+	for (i = 0; i < nr; ++i) {
+		if (get_user(uptr, ptr32 + i))
+			goto out;
+		if (put_user((u64)compat_ptr(uptr), ptr64 + i))
+			goto out;
+	}
+	ret = 0;
+out:
+	return ret;
+}
+
+#define MAX_AIO_SUBMITS 	(PAGE_SIZE/sizeof(struct iocb *))
+
+asmlinkage long
+compat_sys_io_submit(aio_context_t ctx_id, int nr, u32 *iocb)
+{
+	struct iocb **iocb64; 
+	long ret;
+
+	if (unlikely(nr < 0))
+		return -EINVAL;
+
+	if (nr > MAX_AIO_SUBMITS)
+		nr = MAX_AIO_SUBMITS;
+	
+	iocb64 = compat_alloc_user_space(nr * sizeof(*iocb64));
+	ret = copy_iocb(nr, iocb, (u64 *) iocb64);
+	if (ret)
+		goto out;
+	ret = sys_io_submit(ctx_id, nr, iocb64);
+out:
+	return ret;
+}

--------------080902090407000505030208
Content-Type: text/plain;
 name="arch.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="arch.patch"

===== arch/ia64/ia32/ia32_entry.S 1.30 vs edited =====
--- 1.30/arch/ia64/ia32/ia32_entry.S	Tue Oct 21 12:34:11 2003
+++ edited/arch/ia64/ia32/ia32_entry.S	Tue Oct 28 13:54:47 2003
@@ -427,52 +427,57 @@
 	data8 sys_ni_syscall		/* reserved for Security */
 	data8 sys_gettid
 	data8 sys_readahead	  /* 225 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	/* 230 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	/* 235 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
+	data8 sys_setxattr
+	data8 sys_lsetxattr
+	data8 sys_fsetxattr
+	data8 sys_getxattr
+	data8 sys_lgetxattr	/* 230 */
+	data8 sys_fgetxattr
+	data8 sys_listxattr
+	data8 sys_llistxattr
+	data8 sys_flistxattr
+	data8 sys_removexattr	/* 235 */
+	data8 sys_lremovexattr
+	data8 sys_fremovexattr
 	data8 sys_tkill
-	data8 sys_ni_syscall
+	data8 sys_sendfile64
 	data8 compat_sys_futex	/* 240 */
 	data8 compat_sys_sched_setaffinity
 	data8 compat_sys_sched_getaffinity
 	data8 sys32_set_thread_area
 	data8 sys32_get_thread_area
-	data8 sys_ni_syscall	/* 245 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	/* 250 */
+	data8 compat_sys_io_setup	/* 245 */
+	data8 sys_io_destroy
+	data8 compat_sys_io_getevents
+	data8 compat_sys_io_submit
+	data8 sys_io_cancel
+	data8 sys_fadvise64	/* 250 */
 	data8 sys_ni_syscall
 	data8 sys_exit_group
-	data8 sys_ni_syscall
+	data8 sys_lookup_dcookie
 	data8 sys_epoll_create
 	data8 sys32_epoll_ctl	/* 255 */
 	data8 sys32_epoll_wait
 	data8 sys_remap_file_pages
 	data8 sys_set_tid_address
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	/* 260 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	/* 265 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
+	data8 sys32_timer_create
+	data8 compat_timer_settime	/* 260 */
+	data8 compat_timer_gettime
+	data8 sys_timer_getoverrun
+	data8 sys_timer_delete
+	data8 compat_clock_settime
+	data8 compat_clock_gettime /* 265 */
+	data8 compat_clock_getres
+	data8 compat_clock_nanosleep
 	data8 sys_statfs64
 	data8 sys_fstatfs64
+	data8 sys_tgkill	/* 270 */
+	data8 compat_sys_utimes
+	data8 sys32_fadvise64_64
+	data8 sys_ni_syscall
 	data8 sys_ni_syscall
-	
+	data8 sys_ni_syscall	/* 275 */
+
 	/*
 	 *  CAUTION: If any system calls are added beyond this point
 	 *	then the check in `arch/ia64/kernel/ivt.S' will have
===== arch/ia64/ia32/ia32priv.h 1.8 vs edited =====
--- 1.8/arch/ia64/ia32/ia32priv.h	Tue Oct 21 13:54:13 2003
+++ edited/arch/ia64/ia32/ia32priv.h	Tue Oct 28 13:31:03 2003
@@ -251,6 +251,19 @@
 	} _sifields;
 } siginfo_t32;
 
+typedef struct sigevent32{
+	sigval_t32 sigev_value;
+	int sigev_signo;
+	int sigev_notify;
+	union {
+		int _pad[SIGEV_PAD_SIZE32];
+		struct {
+			u32 _function;
+			u32 _attribute; /* really pthread_attr_t */
+		} _sigev_thread;
+	} _sigev_un;
+} sigevent_t32;
+
 struct old_linux32_dirent {
 	u32	d_ino;
 	u32	d_offset;
===== arch/ia64/ia32/sys_ia32.c 1.83 vs edited =====
--- 1.83/arch/ia64/ia32/sys_ia32.c	Tue Oct 21 12:34:11 2003
+++ edited/arch/ia64/ia32/sys_ia32.c	Tue Oct 28 15:55:54 2003
@@ -2925,6 +2925,54 @@
 	return 0;
 }
 
+extern asmlinkage long
+sys_timer_create(clockid_t which_clock, struct sigevent *timer_event_spec,
+		 timer_t * created_timer_id);
+
+asmlinkage long
+sys32_timer_create(u32 clock, struct sigevent32 *se32, timer_t *timer_id)
+{
+	struct sigevent se;
+	mm_segment_t oldfs;
+	timer_t t;
+	long err;
+
+	if (se32 == NULL)
+		return sys_timer_create(clock, NULL, timer_id);
+
+	memset(&se, 0, sizeof(struct sigevent));
+	if (get_user(se.sigev_value.sival_int,	&se32->sigev_value.sival_int) ||
+	    __get_user(se.sigev_signo, &se32->sigev_signo) ||
+	    __get_user(se.sigev_notify, &se32->sigev_notify) ||
+	    __copy_from_user(&se._sigev_un._pad, &se32->_sigev_un._pad,
+	    sizeof(se._sigev_un._pad)))
+		return -EFAULT;
+
+	if (!access_ok(VERIFY_WRITE,timer_id,sizeof(timer_t)))
+		return -EFAULT;
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	err = sys_timer_create(clock, &se, &t);
+	set_fs(oldfs);
+
+	if (!err)
+		err = __put_user (t, timer_id);
+
+	return err;
+}
+
+extern long sys_fadvise64_64(int fd, loff_t offset, loff_t len, int advice);
+
+long sys32_fadvise64_64(int fd, __u32 offset_low, __u32 offset_high, 
+			__u32 len_low, __u32 len_high, int advice)
+{ 
+	return sys_fadvise64_64(fd,
+			       (((u64)offset_high)<<32) | offset_low,
+			       (((u64)len_high)<<32) | len_low,
+			       advice); 
+} 
+
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
 
 struct ncp_mount_data32 {
===== arch/ia64/kernel/ivt.S 1.23 vs edited =====
--- 1.23/arch/ia64/kernel/ivt.S	Fri Jun 20 13:16:06 2003
+++ edited/arch/ia64/kernel/ivt.S	Tue Oct 28 13:31:03 2003
@@ -1513,7 +1513,7 @@
 	alloc r15=ar.pfs,0,0,6,0	// must first in an insn group
 	;;
 	ld4 r8=[r14],8		// r8 == eax (syscall number)
-	mov r15=270		// number of entries in ia32 system call table
+	mov r15=275		// number of entries in ia32 system call table
 	;;
 	cmp.ltu.unc p6,p7=r8,r15
 	ld4 out1=[r14],8	// r9 == ecx
===== include/asm-ia64/siginfo.h 1.14 vs edited =====
--- 1.14/include/asm-ia64/siginfo.h	Tue Aug 19 23:13:39 2003
+++ edited/include/asm-ia64/siginfo.h	Tue Oct 28 13:31:02 2003
@@ -9,7 +9,7 @@
 #define SI_PAD_SIZE	((SI_MAX_SIZE/sizeof(int)) - 4)
 
 #define SIGEV_PAD_SIZE	((SIGEV_MAX_SIZE/sizeof(int)) - 4)
-
+#define SIGEV_PAD_SIZE32 ((SIGEV_MAX_SIZE/sizeof(int)) - 3)
 #define HAVE_ARCH_SIGINFO_T
 #define HAVE_ARCH_COPY_SIGINFO
 #define HAVE_ARCH_COPY_SIGINFO_TO_USER

--------------080902090407000505030208--

