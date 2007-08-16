From: Andrew Burgess <andrew@transitive.com>
Date: Thu, 16 Aug 2007 07:21:29 +0000
Subject: Re: [PATCH] Failure to grow RBS
Message-Id: <20070816072128.GD16695@transitive.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070813132350.GC14980@transitive.com>
In-Reply-To: <20070813132350.GC14980@transitive.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Luck, Tony <tony.luck@intel.com> [2007-08-15 13:46:39 -0700]:

> But it looks on paper like this solves the RBS case.
>
> Needs a "Signed-off-by" line.

Apologies, this is my first kernel patch, so I'm still learning :)

Signed-off-by: Andrew Burgess <andrew@transitive.com>

diff -urp linux-2.6.18/arch/ia64/mm/fault.c linux-2.6.18/arch/ia64/mm/fault.c
--- linux-2.6.18/arch/ia64/mm/fault.c   2006-09-20 04:42:06.000000000 +0100
+++ linux-2.6.18/arch/ia64/mm/fault.c   2007-08-07 08:18:11.000000000 +0100
@@ -125,11 +125,17 @@ ia64_do_page_fault (unsigned long addres
        down_read(&mm->mmap_sem);
 
        vma = find_vma_prev(mm, address, &prev_vma);
-       if (!vma)
+       if (!vma && !prev_vma )
                goto bad_area;
 
-       /* find_vma_prev() returns vma such that address < vma->vm_end or NULL */
-       if (address < vma->vm_start)
+        /*
+         * find_vma_prev() returns vma such that address < vma->vm_end or NULL
+         *
+         * May find no vma, but could be that the last vm area is the
+         * register backing store that needs to expand upwards, in
+         * this case vma will be null, but prev_vma will ne non-null
+         */
+        if (( !vma && prev_vma ) || (address < vma->vm_start) )
                goto check_expansion;
 
   good_area:
@@ -184,6 +190,8 @@ ia64_do_page_fault (unsigned long addres
 
   check_expansion:
        if (!(prev_vma && (prev_vma->vm_flags & VM_GROWSUP) && (address = prev_vma->vm_end))) {
+               if (!vma)
+                       goto bad_area;
                if (!(vma->vm_flags & VM_GROWSDOWN))
                        goto bad_area;
                if (REGION_NUMBER(address) != REGION_NUMBER(vma->vm_start)
