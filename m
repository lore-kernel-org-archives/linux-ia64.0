From: root <davidm@hpl.hp.com>
Date: Tue, 12 Jun 2001 06:32:00 +0000
Subject: Re: [Linux-ia64] problem with mmap?
Message-Id: <marc-linux-ia64-105590693005714@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005712@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005712@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 11 Jun 2001 16:56:55 -0600, Bdale Garbee <bdale@gag.com> said:

  Bdale> In chasing down a problem in the Debian installation toolset
  Bdale> where sed was generating no output when processing
  Bdale> /proc/mounts, we discovered what looks like a bug.

  Bdale> The kernel is allowing an mmap of /proc/mounts to succeed,
  Bdale> which gives sed a 0-byte mmap'ed file.  On other
  Bdale> architectures, the mmap fails so sed resorts to normal
  Bdale> reading which works fine.

Good catch!  This was caused by an accidental reversal of two
special-case/error tests.  This had the effect that a zero-length
mmap() would always succeed, even though it should fail with EBADF on
a non-anonymous mmap() of a file that doesn't support the mmap()
operation (as is the case for /proc/mounts).

The attached patch fixes the problem.

Thanks,

	--davidm

--- arch/ia64/kernel/sys_ia64.c~	Sun Apr 29 17:12:35 2001
+++ arch/ia64/kernel/sys_ia64.c	Mon Jun 11 22:27:42 2001
@@ -178,11 +178,22 @@
 	unsigned long roff;
 	struct file *file = 0;
 
+	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+	if (!(flags & MAP_ANONYMOUS)) {
+		file = fget(fd);
+		if (!file)
+			return -EBADF;
+
+		if (!file->f_op || !file->f_op->mmap)
+			return -ENODEV;
+	}
+
 	/*
-	 * A zero mmap always succeeds in Linux, independent of
-	 * whether or not the remaining arguments are valid.
+	 * A zero mmap always succeeds in Linux, independent of whether or not the
+	 * remaining arguments are valid.
 	 */
-	if (PAGE_ALIGN(len) = 0)
+	len = PAGE_ALIGN(len);
+	if (len = 0)
 		return addr;
 
 	/* don't permit mappings into unmapped space or the virtual page table of a region: */
@@ -193,13 +204,6 @@
 	/* don't permit mappings that would cross a region boundary: */
 	if (rgn_index(addr) != rgn_index(addr + len))
 		return -EINVAL;
-
-	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	if (!(flags & MAP_ANONYMOUS)) {
-		file = fget(fd);
-		if (!file)
-			return -EBADF;
-	}
 
 	down_write(&current->mm->mmap_sem);
 	addr = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);

