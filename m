From: David Gibson <david@gibson.dropbear.id.au>
Date: Thu, 15 Apr 2004 07:25:35 +0000
Subject: Re: hugetlb demand paging patch part [3/3]
Message-Id: <20040415072535.GF25560@zax>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404132325.i3DNPXF21289@unix-os.sc.intel.com>
In-Reply-To: <200404132325.i3DNPXF21289@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, 'Andrew Morton' <akpm@osdl.org>

[snip]
> @@ -209,13 +117,10 @@ follow_huge_pmd(struct mm_struct *mm, un
>  	struct page *page;
> 
>  	page = pte_page(*(pte_t *)pmd);
> -	if (page) {
> +	if (page)
>  		page += ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
> -		get_page(page);
> -	}
>  	return page;
>  }
> -#endif

[snip]

> @@ -175,7 +132,6 @@ struct page *follow_huge_addr(struct mm_
>  		return NULL;
>  	page = pte_page(*ptep);
>  	page += ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
> -	get_page(page);
>  	return page;
>  }

As far as I can tell, the removal of these get_page()s is also
unrelated to the demand paging per se.  But afaict removing them is
correct - the corresponding logic in follow_page() for normal pages
doesn't appear to do a get_page(), nor do all archs do a get_page().

Does that sound right to you?

If so, the patch below ought to be safe (and indeed a bugfix) to apply
now:

Index: working-2.6/arch/ppc64/mm/hugetlbpage.c
=================================--- working-2.6.orig/arch/ppc64/mm/hugetlbpage.c	2004-04-15 17:03:43.052825264 +1000
+++ working-2.6/arch/ppc64/mm/hugetlbpage.c	2004-04-15 17:25:11.450920656 +1000
@@ -314,10 +314,8 @@
 	BUG_ON(! pmd_hugepage(*pmd));
 
 	page = hugepte_page(*(hugepte_t *)pmd);
-	if (page) {
+	if (page)
 		page += ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
-		get_page(page);
-	}
 	return page;
 }
 
Index: working-2.6/arch/i386/mm/hugetlbpage.c
=================================--- working-2.6.orig/arch/i386/mm/hugetlbpage.c	2004-04-15 17:07:42.813857792 +1000
+++ working-2.6/arch/i386/mm/hugetlbpage.c	2004-04-15 17:25:40.837847480 +1000
@@ -111,7 +111,6 @@
 
 	WARN_ON(!PageCompound(page));
 
-	get_page(page);
 	return page;
 }
 
@@ -167,10 +166,8 @@
 	struct page *page;
 
 	page = pte_page(*(pte_t *)pmd);
-	if (page) {
+	if (page)
 		page += ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
-		get_page(page);
-	}
 	return page;
 }
 #endif
Index: working-2.6/arch/ia64/mm/hugetlbpage.c
=================================--- working-2.6.orig/arch/ia64/mm/hugetlbpage.c	2004-04-15 17:08:30.667905672 +1000
+++ working-2.6/arch/ia64/mm/hugetlbpage.c	2004-04-15 17:26:02.309910776 +1000
@@ -133,7 +133,6 @@
 	ptep = huge_pte_offset(mm, addr);
 	page = pte_page(*ptep);
 	page += ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
-	get_page(page);
 	return page;
 }
 int pmd_huge(pmd_t pmd)


-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
