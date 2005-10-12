From: Robin Holt <holt@sgi.com>
Date: Wed, 12 Oct 2005 02:28:40 +0000
Subject: [Patch 1/2] Add a NOPAGE_FAULTED flag to do_no_page.
Message-Id: <20051012022840.GB32360@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051012022627.GA32360@lnx-holt.americas.sgi.com>
In-Reply-To: <20051012022627.GA32360@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-mm@kvack.org

Introduce a NOPAGE_FAULTED flag.  This flag is
returned from a drivers nopage handler to indicate
the desired pte has been inserted and should be handled
as a minor fault.

Signed-off-by: holt@sgi.com


Index: linux-2.6/include/linux/mm.h
=================================--- linux-2.6.orig/include/linux/mm.h	2005-10-11 20:16:07.430703923 -0500
+++ linux-2.6/include/linux/mm.h	2005-10-11 20:16:37.798546969 -0500
@@ -619,6 +619,7 @@ static inline int page_mapped(struct pag
  */
 #define NOPAGE_SIGBUS	(NULL)
 #define NOPAGE_OOM	((struct page *) (-1))
+#define NOPAGE_FAULTED	((struct page *) (-2))
 
 /*
  * Different kinds of faults, as returned by handle_mm_fault().
Index: linux-2.6/mm/memory.c
=================================--- linux-2.6.orig/mm/memory.c	2005-10-11 20:16:09.918718614 -0500
+++ linux-2.6/mm/memory.c	2005-10-11 20:16:37.843464040 -0500
@@ -1862,6 +1862,14 @@ retry:
 		return VM_FAULT_SIGBUS;
 	if (new_page = NOPAGE_OOM)
 		return VM_FAULT_OOM;
+	if (new_page = NOPAGE_FAULTED) {
+		spin_lock(&mm->page_table_lock);
+		page_table = pte_offset_map(pmd, address);
+		pte_unmap(page_table);
+		spin_unlock(&mm->page_table_lock);
+
+		return VM_FAULT_MINOR;
+	}
 
 	/*
 	 * Should we do an early C-O-W break?
