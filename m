From: Uros Prestor <uros@turbolinux.com>
Date: Thu, 17 Aug 2000 07:26:58 +0000
Subject: Re: [Linux-ia64] building glibc
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------4B02FC2AFAE9B4A86AE6B510"
Message-Id: <marc-linux-ia64-105590678205345@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205334@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------4B02FC2AFAE9B4A86AE6B510
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Alan Au wrote:

> It gets a bit furthur now but gets the following error:
>
> make[2]: Entering directory `/home/alanau/src/glibc/glibc-2.1-hjl/sunrpc'
> /home/alanau/glibc-build/elf/ld-linux.so.2 --library-path
> /home/alanau/glibc-build:/home/alanau/glibc-build/math:/home/alanau/glibc-build/elf:/home/alanau/glibc-build/nss:/home/alanau/glibc-build/nis:/home/alanau/glibc-build/db2:/home/alanau/glibc-build/rt:/home/alanau/glibc-build/resolv
> /home/alanau/glibc-build/sunrpc/rpcgen -Y `gcc -print-file-name=cpp | sed
> "s|/cpp$||"` -c rpcsvc/bootparam_prot.x -o
> /home/alanau/glibc-build/sunrpc/xbootparam_prot.T
> doSyscall: unimplemented system call 1212
> /home/alanau/glibc-build/sunrpc/rpcgen: error in loading shared
> libraries: /home/alanau/glibc-build/sunrpc/rpcgen: cannot stat shared
> object: Error 38
> make[2]: *** [/home/alanau/glibc-build/sunrpc/xbootparam_prot.stmp] Error
> 127

I saw this when building glibc on 2.4.0-test1 kernels when IA-64 patch introduced new stat/fstat/lstat interfaces.  You need an extra patch (included below courtesy of David M) which solves the problem.

Uros


--
Uros Prestor
uros@turbolinux.com



--------------4B02FC2AFAE9B4A86AE6B510
Content-Type: text/plain; charset=us-ascii;
 name="glibc-2.1-ia64-syscalls.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="glibc-2.1-ia64-syscalls.patch"

--- sysdeps/unix/sysv/linux/ia64/syscalls.list~	Tue May  9 17:59:12 2000
+++ sysdeps/unix/sysv/linux/ia64/syscalls.list	Mon Jun 19 20:55:36 2000
@@ -72,11 +72,11 @@
 s_getdents	getdents getdents	3	__syscall_getdents	getdents
 
 # System calls with wrappers.
-sys_fstat	fxstat	fstat		2	__syscall_fstat
-sys_lstat	lxstat	lstat		2	__syscall_lstat
+sys_fstat	fxstat	old_fstat	2	__syscall_fstat
+sys_lstat	lxstat	old_lstat	2	__syscall_lstat
 sys_mknod	xmknod	mknod		3	__syscall_mknod
 sys_readv	readv	readv		3	__syscall_readv
-sys_stat	xstat	stat		2	__syscall_stat
+sys_stat	xstat	old_stat	2	__syscall_stat
 sys_writev	writev	writev		3	__syscall_writev
 s_getpagesize	getpagesize getpagesize	0	__syscall_getpagesize
 s_poll		poll	poll		3	__syscall_poll


--------------4B02FC2AFAE9B4A86AE6B510--


