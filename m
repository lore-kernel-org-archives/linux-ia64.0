From: "H . J . Lu" <hjl@valinux.com>
Date: Tue, 21 Nov 2000 16:58:03 +0000
Subject: Re: [Linux-ia64] gcc and glibc: big troubles
Message-Id: <marc-linux-ia64-105590678205758@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 21, 2000 at 05:00:44PM +0100, Jes Sorensen wrote:
> >>>>> "Francis" = Francis Galiegue <fg@mandrakesoft.com> writes:
> 
> Francis> I'm trying to upgrade my glibc and compiler to 001024
> Francis> snapshot + RCS patches up to 037 (for gcc) and glibc 2.2 plus
> Francis> patches (not CVS), but it fails on the whole... Compiler used
> Francis> is 001024 snapshot but with backward compatibility ABI patch
> Francis> applied.
> 
> Francis> First, glibc. I obtain this error:
> 
> Please read the warning messages from the compiler when you compile
> glibc and get errors like this. Higher up in the compiler output it
> had warned you that it couldn't find the definition of
> __NR_getpagesize(). It's because David took it out as we are switching
> to AT_PAGESZ support instead. Until glibc gets fixed you can just
> reenable it in include/asm/unistd.h.
> 

This is an untested patch. Let me know what you get.

Thanks.


H.J.
----
2000-11-21  H.J. Lu  <hjl@gnu.org>

	* sysdeps/unix/sysv/linux/ia64/getpagesize.c (__getpagesize):
	Don't call __syscall_getpagesize. Set to 8K by default.

	* sysdeps/unix/sysv/linux/ia64/syscalls.list (s_getpagesize):
	Removed.

Index: sysdeps/unix/sysv/linux/ia64/getpagesize.c
=================================RCS file: /work/cvs/gnu/glibc/sysdeps/unix/sysv/linux/ia64/getpagesize.c,v
retrieving revision 1.1.1.1
diff -u -p -r1.1.1.1 getpagesize.c
--- sysdeps/unix/sysv/linux/ia64/getpagesize.c	2000/06/25 16:02:54	1.1.1.1
+++ sysdeps/unix/sysv/linux/ia64/getpagesize.c	2000/11/21 16:48:07
@@ -27,19 +27,13 @@
    determine the page size to ensure proper alignment for calls such
    as mmap and friends.  --davidm 99/11/30 */
 
-/* If we are not a static program, this value is collected from the system
-   via the AT_PAGESZ auxiliary argument.  If we are a static program, we
-   use the getpagesize system call.  */
-
 extern size_t _dl_pagesize;
 
-extern size_t __syscall_getpagesize (void);
-
 int
 __getpagesize ()
 {
   if (_dl_pagesize = 0)
-    _dl_pagesize = INLINE_SYSCALL (getpagesize, 0);
+    _dl_pagesize = 8192;	/* use a reasonable default */
   return _dl_pagesize;
 }
 
Index: sysdeps/unix/sysv/linux/ia64/syscalls.list
=================================RCS file: /work/cvs/gnu/glibc/sysdeps/unix/sysv/linux/ia64/syscalls.list,v
retrieving revision 1.1.1.8
diff -u -p -r1.1.1.8 syscalls.list
--- sysdeps/unix/sysv/linux/ia64/syscalls.list	2000/09/16 06:41:37	1.1.1.8
+++ sysdeps/unix/sysv/linux/ia64/syscalls.list	2000/11/21 16:47:02
@@ -72,7 +72,6 @@ s_getdents64	getdents64 getdents64	i:ipi
 s_mknod		xmknod	mknod		i:sii	__syscall_mknod
 s_readv		readv	readv		i:ipi	__syscall_readv
 s_writev	writev	writev		i:ipi	__syscall_writev
-s_getpagesize	getpagesize getpagesize	0	__syscall_getpagesize
 s_poll		poll	poll		i:pii	__syscall_poll
 s_reboot	reboot	reboot		i:iii	__syscall_reboot
 s_ustat		ustat	ustat		i:ip	__syscall_ustat

