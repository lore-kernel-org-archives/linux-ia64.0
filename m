From: Brett Johnson <brett@fc.hp.com>
Date: Mon, 28 Nov 2005 16:45:47 +0000
Subject: Re: initrd_size inflation breaks initramfs
Message-Id: <1133196347.16188.4.camel@localhost.localdomain>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-RNklbocQt6yqtWVzbhB/"
List-Id: <linux-ia64.vger.kernel.org>
References: <1133159027.6062.98.camel@localhost>
In-Reply-To: <1133159027.6062.98.camel@localhost>
To: linux-ia64@vger.kernel.org


--=-RNklbocQt6yqtWVzbhB/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2005-11-28 at 09:28 -0700, dann frazier wrote:
> Ah - found the sourceforge page - looks like a patch to fix this went in
> in February, but just missed the 3.5pre1 release.

Here's the actual patch that I applied to 3.5pre1 to fix this bug.  Man,
I really need to make another release...

-- 
Brett Johnson <brett@hp.com>

--=-RNklbocQt6yqtWVzbhB/
Content-Disposition: attachment; filename=initrd-changes.diff
Content-Type: text/x-patch; name=initrd-changes.diff; charset=us-ascii
Content-Transfer-Encoding: 7bit

Index: elilo.c
===================================================================
RCS file: /cvsroot/elilo/elilo/elilo.c,v
retrieving revision 1.3
retrieving revision 1.6
diff -b -B -u -r1.3 -r1.6
--- elilo.c	20 Feb 2004 22:30:37 -0000	1.3
+++ elilo.c	28 Feb 2005 17:57:28 -0000	1.6
@@ -164,7 +163,7 @@
 
 	for(;;) {
 		kname[0] = cmdline_tmp[0] = cmdline[0] = CHAR_NULL;
-		imem.start_addr = 0; imem.pgcnt = 0;
+		imem.start_addr = 0; imem.pgcnt = 0; imem.size = 0;
 		elilo_opt.sys_img_opts = NULL;
 
 		if (kernel_chooser(argv, argc, index, kname, cmdline_tmp) == -1) goto exit_error;
Index: elilo.h
===================================================================
RCS file: /cvsroot/elilo/elilo/elilo.h,v
retrieving revision 1.3
retrieving revision 1.4
diff -b -B -u -r1.3 -r1.4
--- elilo.h	20 Feb 2004 22:30:37 -0000	1.3
+++ elilo.h	28 Feb 2005 17:57:28 -0000	1.4
@@ -112,6 +112,7 @@
 typedef struct {
 	VOID 	*start_addr;
 	UINTN	pgcnt;
+	UINTN	size;
 } memdesc_t;
 
 typedef struct {
Index: initrd.c
===================================================================
RCS file: /cvsroot/elilo/elilo/initrd.c,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -b -B -u -r1.1.1.1 -r1.2
--- initrd.c	19 Aug 2003 16:47:18 -0000	1.1.1.1
+++ initrd.c	28 Feb 2005 17:57:28 -0000	1.2
@@ -66,10 +66,10 @@
 		goto error;
 	}
 	
-	/* round up to get required number of pages (4KB) */
-	initrd->pgcnt = pgcnt = EFI_SIZE_TO_PAGES(size);
-
+	initrd->size = size;
 
+	/* round up to get required number of pages (4KB) */
+	initrd->pgcnt = pgcnt = EFI_SIZE_TO_PAGES(initrd->size);
 
 	start_addr = alloc_pages(pgcnt, EfiLoaderData, start_addr ? AllocateAddress : AllocateAnyPages, start_addr);
 	if (start_addr == NULL) {
@@ -77,11 +77,11 @@
 		goto error;
 	}
 	VERB_PRT(2, Print(L"initrd: total_size: %ld bytes base: 0x%lx pages %d\n", 
-			size, (UINT64)start_addr, pgcnt));
+			initrd->size, (UINTN)start_addr, pgcnt));
 
 	Print(L"Loading initrd %s...", filename);
 
-	ret = read_file(fd, size, start_addr);	
+	ret = read_file(fd, initrd->size, start_addr);	
 
 	fops_close(fd);
 
@@ -105,6 +105,7 @@
 	 */
 	initrd->start_addr = 0;
 	initrd->pgcnt      = 0;
+	initrd->size       = 0;
 
 	return ret;
 }
Index: ia32/system.c
===================================================================
RCS file: /cvsroot/elilo/elilo/ia32/system.c,v
retrieving revision 1.2
retrieving revision 1.3
diff -b -B -u -r1.2 -r1.3
--- ia32/system.c	17 Feb 2004 23:42:41 -0000	1.2
+++ ia32/system.c	28 Feb 2005 17:57:30 -0000	1.3
@@ -270,7 +270,7 @@
 	if (initrd->start_addr && initrd->pgcnt) {
 		/* %%TBD - This will probably have to be changed. */
 		bp->s.initrd_start = (UINT32)initrd->start_addr;
-		bp->s.initrd_size = (UINT32)(initrd->pgcnt * EFI_PAGE_SIZE);
+		bp->s.initrd_size = (UINT32)(initrd->size);
 
 		/*
 		 * This is the RAMdisk root device for RedHat 2.2.x
Index: ia64/system.c
===================================================================
RCS file: /cvsroot/elilo/elilo/ia64/system.c,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -b -B -u -r1.1.1.1 -r1.2
--- ia64/system.c	19 Aug 2003 16:46:49 -0000	1.1.1.1
+++ ia64/system.c	28 Feb 2005 17:57:30 -0000	1.2
@@ -64,7 +64,7 @@
 	bp->efi_memdesc_version = mdesc.desc_version;
 	bp->command_line	= (UINTN)cmdline;
 	bp->initrd_start	= (UINTN) initrd->start_addr;
-	bp->initrd_size		= initrd->pgcnt << EFI_PAGE_SHIFT;
+	bp->initrd_size		= initrd->size;
 
 	/* fetch console parameters: */
 	conout = systab->ConOut;

--=-RNklbocQt6yqtWVzbhB/--

