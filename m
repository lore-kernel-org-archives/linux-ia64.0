From: Christoph Hellwig <hch@lst.de>
Date: Mon, 01 Sep 2008 16:18:10 +0000
Subject: [PATCH] ia64: kill sys32_pipe
Message-Id: <20080901161810.GA16320@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

It's just a duplicate of the generic sys_pipe that still lacks the
recently added =E6rror handling.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/arch/ia64/ia32/ia32_entry.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/ia32/ia32_entry.S	2008=
-09-01 09:30:25.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/ia32_entry.S	2008-09-01 09:32:08.000000000 -03=
00
@@ -215,7 +215,7 @@ ia32_syscall_table:
 	data8 sys_mkdir
 	data8 sys_rmdir		  /* 40 */
 	data8 sys_dup
-	data8 sys32_pipe
+	data8 sys_pipe
 	data8 compat_sys_times
 	data8 sys_ni_syscall	  /* old prof syscall holder */
 	data8 sys32_brk		  /* 45 */
Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/ia32/sys_ia32.c	2008-0=
9-01 09:31:49.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/sys_ia32.c	2008-09-01 09:32:34.000000000 -0300
@@ -1098,21 +1098,6 @@ sys32_mremap (unsigned int addr, unsigne
 	return ret;
 }
=20
-asmlinkage long
-sys32_pipe (int __user *fd)
-{
-	int retval;
-	int fds[2];
-
-	retval =3D do_pipe_flags(fds, 0);
-	if (retval)
-		goto out;
-	if (copy_to_user(fd, fds, sizeof(fds)))
-		retval =3D -EFAULT;
-  out:
-	return retval;
-}
-
 static inline long
 get_tv32 (struct timeval *o, struct compat_timeval __user *i)
 {
