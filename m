From: Nathan Scott <nathans@sgi.com>
Date: Wed, 17 Sep 2003 07:10:45 +0000
Subject: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106378281914262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi there,

I've been doing some large filesystem testing on XFS, and noticed
that several of our regression tests are failing.  One particular
problem area is xfsdump and its use of the getdents64 interface.
I believe I've traced the problem back to the definition of ino_t
(aka __kernel_ino_t) as an unsigned int in the platform-specific
headers, and I suspect this should instead be an unsigned long on
IA64.  Here's the rationale:

- all of IA64 userspace (glibc) allows for 64 bit inode numbers;
  see /usr/include/bits/types.h in particular, and __ino_t which
  is used in the stat and getdents64 syscalls.
- when we come into the kernel via sys_getdents64, we call into
  filesystem specific code via fs/readdir.c::vfs_readdir and the
  readdir file operation.
- this passes a filldir_t routine into the fs, which the fs uses
  to fill in the getdents buffer for each directory entry.
- filldir64 from sys_getdents64 makes use of the linux_dirent64
  structure internally (with a u64 d_ino) and is passed an ino_t
  as the inode number.
- so, when we fill in each directory entry we're silently chopping
  off the high 32 bits of the inode number (casting from the XFS
  64 bit inode to the ino_t argument of the filldir routines),
  which causes problems for xfsdump as it is looking at the inode
  numbers in the getdents buffer returned from the kernel.
- I can see no reason to have this restriction on IA64, because
  userspace does allow for 64 bit inode numbers.

Does anyone know why the IA64 platform-specific ino_t definition
is an int and not a long?  Patch below fixes this problem for me
but I wonder if there will be side-effects I haven't considered
(i.e. was there a reason for making this 32 bits originally?).
If not, could the IA64 maintainers push this patch around to the
official kernel trees for me?  (pretty please)

many thanks.

-- 
Nathan


--- /usr/tmp/TmpDir.16879-0/linux/include/asm-ia64/posix_types.h_1.1	Wed Sep 17 16:04:09 2003
+++ linux/include/asm-ia64/posix_types.h	Wed Sep 17 11:29:30 2003
@@ -11,7 +11,7 @@
  */
 
 typedef unsigned int	__kernel_dev_t;
-typedef unsigned int	__kernel_ino_t;
+typedef unsigned long	__kernel_ino_t;
 typedef unsigned int	__kernel_mode_t;
 typedef unsigned int	__kernel_nlink_t;
 typedef long		__kernel_off_t;
