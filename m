From: John Hesterberg <jh@sgi.com>
Date: Tue, 27 Nov 2001 22:03:03 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.16)
Message-Id: <marc-linux-ia64-105590698805552@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > You have renamed numnodes in mm/numa.c, but not in include/linux/mmzone.h,
> > and there are many occurences of "extern int num_compact_nodes" all over
> > the place.  I'm wondering why it was renamed in the first place.
> > 
> > Andreas.
> 
> It was changed because numnodes is ambiguous.  This is part of a
> significant numa/discontig memory change that will be submitted to
> the ia64 2.5 tree.  This little piece came in as part of the SGI SN
> updates, since it's more clear, and the SN code has lots of
> references to it, and only a couple in the non-SN code.

Shoot.  I didn't notice that other platforms also use this.
I didn't mean to bite off that much.  Below is a patch putting
numnodes back in the non-SN files, and I'll let the numa/discontig
effort sort out if they really want to change the name.

John


diff -Naur 2.4.16-ia64/include/asm-ia64/acpi-ext.h 16i/include/asm-ia64/acpi-ext.h
--- 2.4.16-ia64/include/asm-ia64/acpi-ext.h	Tue Nov 27 15:26:31 2001
+++ 16i/include/asm-ia64/acpi-ext.h	Tue Nov 27 21:44:11 2001
@@ -297,7 +297,7 @@
 
 extern int pxm_to_nid_map[MAX_PXM_DOMAINS]; /* _PXM to logical node ID map */
 extern int nid_to_pxm_map[PLAT_MAX_COMPACT_NODES]; /* logical node ID to _PXM map */
-extern int num_compact_nodes;		/* total number of nodes in system */
+extern int numnodes;			/* total number of nodes in system */
 extern int num_memory_chunks;		/* total number of memory chunks */
 
 /*
diff -Naur 2.4.16-ia64/mm/numa.c 16i/mm/numa.c
--- 2.4.16-ia64/mm/numa.c	Tue Nov 27 15:26:32 2001
+++ 16i/mm/numa.c	Tue Nov 27 21:40:38 2001
@@ -9,7 +9,7 @@
 #include <linux/mmzone.h>
 #include <linux/spinlock.h>
 
-int num_compact_nodes = 1;	/* Initialized for UMA platforms */
+int numnodes = 1;	/* Initialized for UMA platforms */
 
 static bootmem_data_t contig_bootmem_data;
 pg_data_t contig_page_data = { bdata: &contig_bootmem_data };

