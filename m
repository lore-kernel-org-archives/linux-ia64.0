From: Christoph Hellwig <hch@lst.de>
Date: Sat, 16 Aug 2008 17:50:28 +0000
Subject: [PATCH] ia64: use generic compat_old_sys_readdir
Message-Id: <20080816175028.GA4960@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Switch ia64 to the generic compat_sys_old_readdir which is identical
except for slightly better error handling.  Also remove sys32_getdents
which already isn't wired up to the syscall table anymore in favour of
compat_sys_getdents.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/arch/ia64/ia32/ia32_entry.S
=================================--- linux-2.6.orig/arch/ia64/ia32/ia32_entry.S	2008-08-16 13:13:13.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/ia32_entry.S	2008-08-16 13:15:23.000000000 -0300
@@ -262,7 +262,7 @@ ia32_syscall_table:
 	data8 sys_uselib
 	data8 sys_swapon
 	data8 sys_reboot
-	data8 sys32_readdir
+	data8 compat_sys_old_readdir
 	data8 sys32_mmap	  /* 90 */
 	data8 sys32_munmap
 	data8 sys_truncate
Index: linux-2.6/arch/ia64/ia32/ia32priv.h
=================================--- linux-2.6.orig/arch/ia64/ia32/ia32priv.h	2008-08-16 13:16:30.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/ia32priv.h	2008-08-16 13:16:44.000000000 -0300
@@ -276,13 +276,6 @@ typedef struct compat_siginfo {
 	} _sifields;
 } compat_siginfo_t;
 
-struct old_linux32_dirent {
-	u32	d_ino;
-	u32	d_offset;
-	u16	d_namlen;
-	char	d_name[1];
-};
-
 /*
  * IA-32 ELF specific definitions for IA-64.
  */
Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
=================================--- linux-2.6.orig/arch/ia64/ia32/sys_ia32.c	2008-08-16 13:15:30.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/sys_ia32.c	2008-08-16 13:17:51.000000000 -0300
@@ -1210,138 +1210,6 @@ sys32_settimeofday (struct compat_timeva
 	return do_sys_settimeofday(tv ? &kts : NULL, tz ? &ktz : NULL);
 }
 
-struct getdents32_callback {
-	struct compat_dirent __user *current_dir;
-	struct compat_dirent __user *previous;
-	int count;
-	int error;
-};
-
-struct readdir32_callback {
-	struct old_linux32_dirent __user * dirent;
-	int count;
-};
-
-static int
-filldir32 (void *__buf, const char *name, int namlen, loff_t offset, u64 ino,
-	   unsigned int d_type)
-{
-	struct compat_dirent __user * dirent;
-	struct getdents32_callback * buf = (struct getdents32_callback *) __buf;
-	int reclen = ROUND_UP(offsetof(struct compat_dirent, d_name) + namlen + 1, 4);
-	u32 d_ino;
-
-	buf->error = -EINVAL;	/* only used if we fail.. */
-	if (reclen > buf->count)
-		return -EINVAL;
-	d_ino = ino;
-	if (sizeof(d_ino) < sizeof(ino) && d_ino != ino)
-		return -EOVERFLOW;
-	buf->error = -EFAULT;	/* only used if we fail.. */
-	dirent = buf->previous;
-	if (dirent)
-		if (put_user(offset, &dirent->d_off))
-			return -EFAULT;
-	dirent = buf->current_dir;
-	buf->previous = dirent;
-	if (put_user(d_ino, &dirent->d_ino)
-	    || put_user(reclen, &dirent->d_reclen)
-	    || copy_to_user(dirent->d_name, name, namlen)
-	    || put_user(0, dirent->d_name + namlen))
-		return -EFAULT;
-	dirent = (struct compat_dirent __user *) ((char __user *) dirent + reclen);
-	buf->current_dir = dirent;
-	buf->count -= reclen;
-	return 0;
-}
-
-asmlinkage long
-sys32_getdents (unsigned int fd, struct compat_dirent __user *dirent, unsigned int count)
-{
-	struct file * file;
-	struct compat_dirent __user * lastdirent;
-	struct getdents32_callback buf;
-	int error;
-
-	error = -EFAULT;
-	if (!access_ok(VERIFY_WRITE, dirent, count))
-		goto out;
-
-	error = -EBADF;
-	file = fget(fd);
-	if (!file)
-		goto out;
-
-	buf.current_dir = dirent;
-	buf.previous = NULL;
-	buf.count = count;
-	buf.error = 0;
-
-	error = vfs_readdir(file, filldir32, &buf);
-	if (error < 0)
-		goto out_putf;
-	error = buf.error;
-	lastdirent = buf.previous;
-	if (lastdirent) {
-		if (put_user(file->f_pos, &lastdirent->d_off))
-			error = -EFAULT;
-		else
-			error = count - buf.count;
-	}
-
-out_putf:
-	fput(file);
-out:
-	return error;
-}
-
-static int
-fillonedir32 (void * __buf, const char * name, int namlen, loff_t offset, u64 ino,
-	      unsigned int d_type)
-{
-	struct readdir32_callback * buf = (struct readdir32_callback *) __buf;
-	struct old_linux32_dirent __user * dirent;
-	u32 d_ino;
-
-	if (buf->count)
-		return -EINVAL;
-	d_ino = ino;
-	if (sizeof(d_ino) < sizeof(ino) && d_ino != ino)
-		return -EOVERFLOW;
-	buf->count++;
-	dirent = buf->dirent;
-	if (put_user(d_ino, &dirent->d_ino)
-	    || put_user(offset, &dirent->d_offset)
-	    || put_user(namlen, &dirent->d_namlen)
-	    || copy_to_user(dirent->d_name, name, namlen)
-	    || put_user(0, dirent->d_name + namlen))
-		return -EFAULT;
-	return 0;
-}
-
-asmlinkage long
-sys32_readdir (unsigned int fd, void __user *dirent, unsigned int count)
-{
-	int error;
-	struct file * file;
-	struct readdir32_callback buf;
-
-	error = -EBADF;
-	file = fget(fd);
-	if (!file)
-		goto out;
-
-	buf.count = 0;
-	buf.dirent = dirent;
-
-	error = vfs_readdir(file, fillonedir32, &buf);
-	if (error >= 0)
-		error = buf.count;
-	fput(file);
-out:
-	return error;
-}
-
 struct sel_arg_struct {
 	unsigned int n;
 	unsigned int inp;
