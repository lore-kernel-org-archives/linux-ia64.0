From: Jack Steiner <steiner@sgi.com>
Date: Mon, 03 May 2004 19:47:32 +0000
Subject: Re: [PATCH] - deleting huge pages
Message-Id: <20040503194732.GA22056@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040502123028.GA13812@sgi.com>
In-Reply-To: <20040502123028.GA13812@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(Update to previous mail - patch updated for latest tree)

If you attempt to allocate a LOT more huge pages than are physically
available, the kernel may reference a NULL pte.

If the mmap fails, do_mmap_pgoff attempts to unmap the vma range it
was mapping. Depending on where it failed during
the mmap, some of the higher level PGD/PMDs may not have been assigned.

The same problem exists in 2.4. I'll post a second patch in a few
days....




--- linux_base/arch/ia64/mm/hugetlbpage.c	2004-05-03 09:36:00.000000000 -0500
+++ linux/arch/ia64/mm/hugetlbpage.c	2004-05-03 14:38:21.000000000 -0500
@@ -245,7 +245,7 @@
 
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		pte = huge_pte_offset(mm, address);
-		if (pte_none(*pte))
+		if (!pte || pte_none(*pte))
 			continue;
 		page = pte_page(*pte);
 		put_page(page);



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


