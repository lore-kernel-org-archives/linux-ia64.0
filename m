From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sat, 20 Nov 2004 00:07:34 +0000
Subject: Re: VM_LOCKED in pci_mmap_page_range?
Message-Id: <200411191607.34798.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_GronBCxufpTFy57"
List-Id: <linux-ia64.vger.kernel.org>
References: <200411191557.55922.jbarnes@engr.sgi.com>
In-Reply-To: <200411191557.55922.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_GronBCxufpTFy57
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday, November 19, 2004 3:57 pm, Jesse Barnes wrote:
> Should pci_mmap_page_range marked the pages as VM_LOCKED that it's about to
> request be remapped via remap_pfn_range?  I'm seeing userspace apps hang on
> mmaping of /proc/bus/pci unless I remove it.

I just read the thread "loops in get_user_pages() for VM_IO" on lkml and it 
appears that VM_LOCKED shouldn't be set for IO mappings.  Or is this fixed 
upstream and I haven't updated my tree?  If not, then this fixes it for me.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_GronBCxufpTFy57
Content-Type: text/plain;
  charset="iso-8859-1";
  name="pci-mmap-reserved-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pci-mmap-reserved-fix.patch"

===== arch/ia64/pci/pci.c 1.59 vs edited =====
--- 1.59/arch/ia64/pci/pci.c	2004-11-05 11:55:25 -08:00
+++ edited/arch/ia64/pci/pci.c	2004-11-19 16:01:45 -08:00
@@ -518,7 +518,7 @@
 	 * Leave vm_pgoff as-is, the PCI space address is the physical
 	 * address on this platform.
 	 */
-	vma->vm_flags |= (VM_SHM | VM_LOCKED | VM_IO);
+	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO);
 
 	if (write_combine)
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);

--Boundary-00=_GronBCxufpTFy57--
