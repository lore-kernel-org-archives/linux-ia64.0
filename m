From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Wed, 22 Feb 2006 03:01:18 +0000
Subject: RE: IA64 non-contiguous memory space bugs
Message-Id: <99FA2ED298A9834DB1BF5DE8BDBF241331834A@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060222001359.GA23574@localhost.localdomain>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: David Gibson <david@gibson.dropbear.id.au>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>-----Original Message-----
>>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-owner@vger.kern=
el.org] On Behalf Of 'David Gibson'
>>Sent: 2006=C4=EA2=D4=C222=C8=D5 10:26
>>To: Chen, Kenneth W
>>Cc: linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
>>Subject: Re: IA64 non-contiguous memory space bugs
>>
>>Your patch below is insufficient, because there's a second test of
>>is_hugepage_only_range() further down.  However, instead of tweaking
>>the tested ranges, I think what we really want to do is check for
>>is_vm_hugetlb_page() instead.
>>
>>I was worried before, but now that you point out it's the 'end'
>>address which really matters, not the ceiling, that might be
>>sufficient.  Um.. except that hugepages, unlike normal pages these
>>days don't necessarily clean up all possible pagetable pages on
>>unmap...  crud.  Still the patch below ought to be an improvement.
>>
>>Index: working-2.6/mm/memory.c
>>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D>>--- working-2.6.orig/mm/memory.c	2006-02-22 10=
:42:14.000000000 +1100
>>+++ working-2.6/mm/memory.c	2006-02-22 13:22:07.000000000 +1100
>>@@ -277,7 +277,7 @@ void free_pgtables(struct mmu_gather **t
>> 		anon_vma_unlink(vma);
>> 		unlink_file_vma(vma);
>>
>>-		if (is_hugepage_only_range(vma->vm_mm, addr, HPAGE_SIZE)) {
>>+		if (is_vm_hugetlb_page(vma)) {
>> 			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
>> 				floor, next? next->vm_start: ceiling);
>> 		} else {
>>@@ -285,8 +285,7 @@ void free_pgtables(struct mmu_gather **t
>> 			 * Optimization: gather nearby vmas into one call down
>> 			 */
>> 			while (next && next->vm_start <=3D vma->vm_end + PMD_SIZE
>>-			  && !is_hugepage_only_range(vma->vm_mm, next->vm_start,
>>-							HPAGE_SIZE)) {
>>+			       && !is_vm_hugetlb_page(vma->vm_mm)) {
is_vm_hugetlb_page(vma->vm_mm) should be is_vm_hugetlb_page(vma)?

