From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Tue, 31 Oct 2000 00:26:37 +0000
Subject: Re: [Linux-ia64] Re: IA-64 XFree86 (was: XFree 4.0.1 module loading)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
Message-Id: <marc-linux-ia64-105590678205641@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205362@msgid-missing>
To: linux-ia64@vger.kernel.org

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii

On Mon, Aug 21, 2000, David Mosberger <davidm@hpl.hp.com> wrote:
>   Mark> 2) No mechanism for the X-server to write combine memory and
>   Mark> no discussions on adding this to Linux as far as I can tell.
>   Mark> There needs to be a new flag to open() or mmap().  There
>   Mark> aren't any MTRRs.
> 
> I submitted a patch for the tdfx DRM module to map non-AGP stuff as
> write-combined (actually, I'm not 100% sure this is the right thing to
> do here; a DRM expert may want to double check this; it does seem to
> work fine on my machine).  See the latest Linux kernel patch.
> 
> Linus already agreed that it would be OK to add additional mmap()
> flags to indicate the memory attribute (normal vs. write-combine
> vs. uncached).  Walt says a patch to do this was developed as part of
> the XFree86 4.0 work at VA and promised to send me a patch.  I don't
> think I have received such a patch, but I'd be happy to merge it
> in. ;-)

Now that we have a stable platform, we were able to test the patch and
confirm the patch wasn't causing the stability problems we were seeing.

This gets a 3 times speed improvement over non write combined memory in
the tests Mark performed.

The patch is against 2.4.0-test9-ia64-001004

JE


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mmap-wrcomb-noncached.patch"

diff -ur linux-2.4.0-test9.orig/drivers/char/mem.c linux-2.4.0-test9/drivers/char/mem.c
--- linux-2.4.0-test9.orig/drivers/char/mem.c	Mon Sep 25 15:26:56 2000
+++ linux-2.4.0-test9/drivers/char/mem.c	Thu Oct 26 15:31:18 2000
@@ -198,8 +198,12 @@
 	 * through a file pointer that was marked O_SYNC will be
 	 * done non-cached.
 	 */
-	if (noncached_address(offset) || (file->f_flags & O_SYNC))
+	if (noncached_address(offset) || (file->f_flags & O_SYNC) ||
+	    vma->vm_flags & VM_NONCACHED)
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+
+	if (vma->vm_flags & VM_WRITECOMBINED)
+		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 
 	/*
 	 * Don't dump addresses that are not real memory to a core file.
diff -ur linux-2.4.0-test9.orig/include/asm-ia64/mman.h linux-2.4.0-test9/include/asm-ia64/mman.h
--- linux-2.4.0-test9.orig/include/asm-ia64/mman.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test9/include/asm-ia64/mman.h	Thu Oct 26 15:04:01 2000
@@ -24,6 +24,9 @@
 #define MAP_LOCKED	0x2000		/* pages are locked */
 #define MAP_NORESERVE	0x4000		/* don't check for reservations */
 
+#define MAP_WRITECOMBINED 0x10000	/* Write combine the area */
+#define MAP_NONCACHED	0x20000		/* Don't cache the memory */
+
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_INVALIDATE	2		/* invalidate the caches */
 #define MS_SYNC		4		/* synchronous memory sync */
diff -ur linux-2.4.0-test9.orig/include/linux/mm.h linux-2.4.0-test9/include/linux/mm.h
--- linux-2.4.0-test9.orig/include/linux/mm.h	Mon Oct  2 11:01:19 2000
+++ linux-2.4.0-test9/include/linux/mm.h	Thu Oct 26 15:30:56 2000
@@ -96,6 +96,9 @@
 #define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
 #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
 
+#define VM_WRITECOMBINED 0x00100000	/* Write combined */
+#define VM_NONCACHED	0x00200000	/* Noncached access */
+
 #define VM_STACK_FLAGS	0x00000177
 
 #define VM_READHINTMASK			(VM_SEQ_READ | VM_RAND_READ)
diff -ur linux-2.4.0-test9.orig/mm/mmap.c linux-2.4.0-test9/mm/mmap.c
--- linux-2.4.0-test9.orig/mm/mmap.c	Tue Aug 29 12:41:12 2000
+++ linux-2.4.0-test9/mm/mmap.c	Mon Oct 30 11:01:13 2000
@@ -151,6 +151,12 @@
 		_trans(prot, PROT_WRITE, VM_WRITE) |
 		_trans(prot, PROT_EXEC, VM_EXEC);
 	flag_bits =
+#ifdef MAP_WRITECOMBINED
+		_trans(flags, MAP_WRITECOMBINED, VM_WRITECOMBINED) |
+#endif
+#ifdef MAP_NONCACHED
+		_trans(flags, MAP_NONCACHED, VM_NONCACHED) |
+#endif
 		_trans(flags, MAP_GROWSDOWN, VM_GROWSDOWN) |
 		_trans(flags, MAP_DENYWRITE, VM_DENYWRITE) |
 		_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE);

--EVF5PPMfhYS0aIcm--

