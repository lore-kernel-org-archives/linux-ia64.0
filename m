From: Nobuhiko Yoshida <n-yoshida@pst.fujitsu.com>
Date: Thu, 01 Apr 2004 09:10:38 +0000
Subject: Re: Hugetlbpages in very large memory machines.......
Message-Id: <JL20040401181038.26780140@pst.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <JM20040316121508.13008671@pst.fujitsu.com>
In-Reply-To: <JM20040316121508.13008671@pst.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org
Cc: raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, Hirokazu Takahashi <taka@valinux.co.jp>, lhms-devel@lists.sourceforge.net

Nobuhiko Yoshida <n-yoshida@pst.fujitsu.com> wrote=81F
> Hello,
>=20
> > > +/*      update_mmu_cache(vma, address, *pte); */
> >=20
> > I have not studied low level IA64 VM in detail, but don't you need
> > some kind of TLB flush here?
>=20
> Oh! Yes.
> Perhaps, TLB flush is needed here.

- Below is the patch that revised what I contributed before.
- I added the flush of TLB and icache.=20

How To Use:
   1. Download linux-2.6.0 source tree
   2. Apply the below patch for linux-2.6.0

Thank you,
Nobuhiko Yoshida

diff -dupr linux-2.6.0/arch/i386/mm/hugetlbpage.c linux-2.6.0.HugeTLB/arch/=
i386/mm/hugetlbpage.c
--- linux-2.6.0/arch/i386/mm/hugetlbpage.c  2003-12-18 11:59:38.000000000 +=
0900
+++ linux-2.6.0.HugeTLB/arch/i386/mm/hugetlbpage.c  2004-04-01 11:48:56.000=
000000 +0900
@@ -142,8 +142,10 @@ int copy_hugetlb_page_range(struct mm_st
            goto nomem;
        src_pte =3D huge_pte_offset(src, addr);
        entry =3D *src_pte;
-       ptepage =3D pte_page(entry);
-       get_page(ptepage);
+       if (!pte_none(entry)) {
+           ptepage =3D pte_page(entry);
+           get_page(ptepage);
+       }
        set_pte(dst_pte, entry);
        dst->rss +=3D (HPAGE_SIZE / PAGE_SIZE);
        addr +=3D HPAGE_SIZE;
@@ -173,6 +175,11 @@ follow_hugetlb_page(struct mm_struct *mm
=20
            pte =3D huge_pte_offset(mm, vaddr);
=20
+           if (!pte || pte_none(*pte)) {
+               hugetlb_fault(mm, vma, 0, vaddr);
+               pte =3D huge_pte_offset(mm, vaddr);
+           }
+
            /* hugetlb should be locked, and hence, prefaulted */
            WARN_ON(!pte || pte_none(*pte));
=20
@@ -261,12 +268,17 @@ int pmd_huge(pmd_t pmd)
 }
=20
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-       pmd_t *pmd, int write)
+follow_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+       unsigned long address, pmd_t *pmd, int write)
 {
    struct page *page;
=20
    page =3D pte_page(*(pte_t *)pmd);
+
+   if (!page) {
+       hugetlb_fault(mm, vma, write, address);
+       page =3D pte_page(*(pte_t *)pmd);
+   }
    if (page) {
        page +=3D ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
        get_page(page);
@@ -527,6 +539,48 @@ int is_hugepage_mem_enough(size_t size)
    return (size + ~HPAGE_MASK)/HPAGE_SIZE <=3D htlbpagemem;
 }
=20
+
+int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma, int wr=
ite_access, unsigned long address)
+{
+   struct file *file =3D vma->vm_file;
+   struct address_space *mapping =3D file->f_dentry->d_inode->i_mapping;
+   struct page *page;
+   unsigned long idx;
+   pte_t *pte;
+   int ret =3D VM_FAULT_MINOR;
+
+   BUG_ON(vma->vm_start & ~HPAGE_MASK);
+   BUG_ON(vma->vm_end & ~HPAGE_MASK);
+
+   spin_lock(&mm->page_table_lock);
+
+   idx =3D ((address - vma->vm_start) >> HPAGE_SHIFT)
+       + (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+   page =3D find_get_page(mapping, idx);
+
+   if (!page) {
+       page =3D alloc_hugetlb_page();
+       if (!page) {
+           ret =3D VM_FAULT_SIGBUS;
+           goto out;
+       }
+       ret =3D add_to_page_cache(page, mapping, idx, GFP_ATOMIC);
+       unlock_page(page);
+       if (ret) {
+           free_huge_page(page);
+           ret =3D VM_FAULT_SIGBUS;
+           goto out;
+       }
+   }
+   pte =3D huge_pte_alloc(mm, address);
+   set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
+/*     update_mmu_cache(vma, address, *pte); */
+out:
+   spin_unlock(&mm->page_table_lock);
+   return ret;
+}
+
+
 /*
  * We cannot handle pagefaults against hugetlb pages at all.  They cause
  * handle_mm_fault() to try to instantiate regular-sized pages in the
diff -dupr linux-2.6.0/arch/ia64/mm/hugetlbpage.c linux-2.6.0.HugeTLB/arch/=
ia64/mm/hugetlbpage.c
--- linux-2.6.0/arch/ia64/mm/hugetlbpage.c  2003-12-18 11:58:56.000000000 +=
0900
+++ linux-2.6.0.HugeTLB/arch/ia64/mm/hugetlbpage.c  2004-03-22 11:29:01.000=
000000 +0900
@@ -170,8 +170,10 @@ int copy_hugetlb_page_range(struct mm_st
            goto nomem;
        src_pte =3D huge_pte_offset(src, addr);
        entry =3D *src_pte;
-       ptepage =3D pte_page(entry);
-       get_page(ptepage);
+       if (!pte_none(entry)) {
+           ptepage =3D pte_page(entry);
+           get_page(ptepage);
+       }  =20
        set_pte(dst_pte, entry);
        dst->rss +=3D (HPAGE_SIZE / PAGE_SIZE);
        addr +=3D HPAGE_SIZE;
@@ -195,6 +197,12 @@ follow_hugetlb_page(struct mm_struct *mm
    do {
        pstart =3D start & HPAGE_MASK;
        ptep =3D huge_pte_offset(mm, start);
+
+       if (!ptep || pte_none(*ptep)) {
+           hugetlb_fault(mm, vma, 0, start);
+           ptep =3D huge_pte_offset(mm, start);
+       }
+
        pte =3D *ptep;
=20
 back1:
@@ -236,6 +244,12 @@ struct page *follow_huge_addr(struct mm_
    pte_t *ptep;
=20
    ptep =3D huge_pte_offset(mm, addr);
+
+   if (!ptep || pte_none(*ptep)) {
+       hugetlb_fault(mm, vma, 0, addr);
+       ptep =3D huge_pte_offset(mm, addr);
+   }
+
    page =3D pte_page(*ptep);
    page +=3D ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
    get_page(page);
@@ -246,7 +260,8 @@ int pmd_huge(pmd_t pmd)
    return 0;
 }
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, i=
nt write)
+follow_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+       unsigned long address, pmd_t *pmd, int write)
 {
    return NULL;
 }
@@ -518,6 +533,49 @@ int is_hugepage_mem_enough(size_t size)
    return 1;
 }
=20
+
+int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma, int wr=
ite_access, unsigned long address)
+{
+   struct file *file =3D vma->vm_file;
+   struct address_space *mapping =3D file->f_dentry->d_inode->i_mapping;
+   struct page *page;
+   unsigned long idx;
+   pte_t *pte;
+   int ret =3D VM_FAULT_MINOR;
+
+   BUG_ON(vma->vm_start & ~HPAGE_MASK);
+   BUG_ON(vma->vm_end & ~HPAGE_MASK);
+
+   spin_lock(&mm->page_table_lock);
+
+   idx =3D ((address - vma->vm_start) >> HPAGE_SHIFT)
+       + (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+   page =3D find_get_page(mapping, idx);
+
+   if (!page) {
+       page =3D alloc_hugetlb_page();
+       if (!page) {
+           ret =3D VM_FAULT_SIGBUS;
+           goto out;
+       }
+       ret =3D add_to_page_cache(page, mapping, idx, GFP_ATOMIC);
+       unlock_page(page);
+       if (ret) {
+           free_huge_page(page);
+           ret =3D VM_FAULT_SIGBUS;
+           goto out;
+       }
+   }
+   pte =3D huge_pte_alloc(mm, address);
+   set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
+   flush_tlb_range(vma, address, address + HPAGE_SIZE);
+   update_mmu_cache(vma, address, *pte);
+out:
+   spin_unlock(&mm->page_table_lock);
+   return ret;
+}
+
+
 static struct page *hugetlb_nopage(struct vm_area_struct * area, unsigned =
long address, int unused)
 {
    BUG();
diff -dupr linux-2.6.0/include/linux/hugetlb.h linux-2.6.0.HugeTLB/include/=
linux/hugetlb.h
--- linux-2.6.0/include/linux/hugetlb.h 2003-12-18 11:58:49.000000000 +0900
+++ linux-2.6.0.HugeTLB/include/linux/hugetlb.h 2003-12-19 09:47:25.0000000=
00 +0900
@@ -23,10 +23,12 @@ struct page *follow_huge_addr(struct mm_
            unsigned long address, int write);
 struct vm_area_struct *hugepage_vma(struct mm_struct *mm,
                    unsigned long address);
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-               pmd_t *pmd, int write);
+struct page *follow_huge_pmd(struct mm_struct *mm, struct vm_area_struct *,
+               unsigned long address, pmd_t *pmd, int write);
 int is_aligned_hugepage_range(unsigned long addr, unsigned long len);
 int pmd_huge(pmd_t pmd);
+extern int hugetlb_fault(struct mm_struct *, struct vm_area_struct *,
+               int, unsigned long);
=20
 extern int htlbpage_max;
=20
@@ -63,6 +65,7 @@ static inline int is_vm_hugetlb_page(str
 #define is_aligned_hugepage_range(addr, len)   0
 #define pmd_huge(x)    0
 #define is_hugepage_only_range(addr, len)  0
+#define hugetlb_fault(mm, vma, write, addr)    0
=20
 #ifndef HPAGE_MASK
 #define HPAGE_MASK 0       /* Keep the compiler happy */
diff -dupr linux-2.6.0/mm/memory.c linux-2.6.0.HugeTLB/mm/memory.c
--- linux-2.6.0/mm/memory.c 2003-12-18 11:58:48.000000000 +0900
+++ linux-2.6.0.HugeTLB/mm/memory.c 2003-12-19 09:47:46.000000000 +0900
@@ -640,7 +640,7 @@ follow_page(struct mm_struct *mm, unsign
    if (pmd_none(*pmd))
        goto out;
    if (pmd_huge(*pmd))
-       return follow_huge_pmd(mm, address, pmd, write);
+       return follow_huge_pmd(mm, vma, address, pmd, write);
    if (pmd_bad(*pmd))
        goto out;
=20
@@ -1603,7 +1603,7 @@ int handle_mm_fault(struct mm_struct *mm
    inc_page_state(pgfault);
=20
    if (is_vm_hugetlb_page(vma))
-       return VM_FAULT_SIGBUS; /* mapping truncation does this. */
+       return hugetlb_fault(mm, vma, write_access, address);
=20
    /*
     * We need the page table lock to synchronize with kswapd
