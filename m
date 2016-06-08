From: Yinghai Lu <yinghai@kernel.org>
Date: Wed, 08 Jun 2016 22:35:16 +0000
Subject: Re: [PATCH v12 01/15] PCI: Let pci_mmap_page_range() take extra resource pointer
Message-Id: <CAE9FiQXPmG6UYYGHG52_i8vaBJ5yPm6Z4Zfx_BhQxVhyWC5fnw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160604000642.28162-1-yinghai@kernel.org>
 <20160604000642.28162-2-yinghai@kernel.org>
 <20160608210322.GA4248@localhost>
In-Reply-To: <20160608210322.GA4248@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Wed, Jun 8, 2016 at 2:03 PM, Bjorn Helgaas <helgaas@kernel.org> wrote:
>
> Microblaze does look up the resource in pci_mmap_page_range(), but it
> never actually uses it.  It *looks* like it uses it, but that code is
> actually dead and I think we should apply the first patch below.

Good one.

>
> That leaves powerpc as the only arch that would use this extra
> resource pointer.  It uses it in __pci_mmap_set_pgprot() to help
> decide whether to make a normal uncacheable mapping or a write-
> combining one.  There's nothing here that's specific to the powerpc
> architecture, and I don't think we should add this parameter just to
> cater to powerpc.
>
> There are two cases where __pci_mmap_set_pgprot() on powerpc does
> something based on the resource:
>
>   1) We're using procfs to mmap I/O port space after we requested
>      write-combining, e.g., we did this:
>
>        ioctl(fd, PCIIOC_MMAP_IS_IO);           # request I/O port space
>        ioctl(fd, PCIIOC_WRITE_COMBINE, 1);     # request write-combining
>        mmap(fd, ...)
>
>      On powerpc, we ignore the write-combining request in this case.
>
>      I think we can handle this case by applying the second patch
>      below to ignore write-combining on I/O space for all arches, not
>      just powerpc.
>
>   2) We're using sysfs to mmap resourceN (not resourceN_wc), and
>      the resource is prefetchable.  On powerpc, we turn *on*
>      write-combining, even though the user didn't ask for it.
>
>      I'm not sure this case is actually safe, because it changes the
>      ordering properties.  If it *is* safe, we could enable write-
>      combining in pci_mmap_resource(), where we already have the
>      resource and it could be done for all arches.
>
>      This case is not strictly necessary, except to avoid a
>      performance regression, because the user could have mapped
>      resourceN_wc to explicitly request write-combining.
>

Agreed.

>
> commit 4e712b691abc5b579e3e4327f56b0b7988bdd1cb
> Author: Bjorn Helgaas <bhelgaas@google.com>
> Date:   Wed Jun 8 14:00:14 2016 -0500
>
>     microblaze/PCI: Remove useless __pci_mmap_set_pgprot()
>
>     The microblaze __pci_mmap_set_pgprot() was apparently copied from powerpc,
>     where it computes either an uncacheable pgprot_t or a write-combining one.
>     But on microblaze, we always use the regular uncacheable pgprot_t.
>
>     Remove the useless code in __pci_mmap_set_pgprot() and inline the
>     pgprot_noncached() at the only caller.
>
>     Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
>
> diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
> index 14cba60..1974567 100644
> --- a/arch/microblaze/pci/pci-common.c
> +++ b/arch/microblaze/pci/pci-common.c
> @@ -219,33 +219,6 @@ static struct resource *__pci_mmap_make_offset(struct pci_dev *dev,
>  }
>
>  /*
> - * Set vm_page_prot of VMA, as appropriate for this architecture, for a pci
> - * device mapping.
> - */
> -static pgprot_t __pci_mmap_set_pgprot(struct pci_dev *dev, struct resource *rp,
> -                                     pgprot_t protection,
> -                                     enum pci_mmap_state mmap_state,
> -                                     int write_combine)
> -{
> -       pgprot_t prot = protection;
> -
> -       /* Write combine is always 0 on non-memory space mappings. On
> -        * memory space, if the user didn't pass 1, we check for a
> -        * "prefetchable" resource. This is a bit hackish, but we use
> -        * this to workaround the inability of /sysfs to provide a write
> -        * combine bit
> -        */
> -       if (mmap_state != pci_mmap_mem)
> -               write_combine = 0;
> -       else if (write_combine = 0) {
> -               if (rp->flags & IORESOURCE_PREFETCH)
> -                       write_combine = 1;
> -       }
> -
> -       return pgprot_noncached(prot);
> -}
> -
> -/*
>   * This one is used by /dev/mem and fbdev who have no clue about the
>   * PCI device, it tries to find the PCI device first and calls the
>   * above routine
> @@ -317,9 +290,7 @@ int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
>                 return -EINVAL;
>
>         vma->vm_pgoff = offset >> PAGE_SHIFT;
> -       vma->vm_page_prot = __pci_mmap_set_pgprot(dev, rp,
> -                                                 vma->vm_page_prot,
> -                                                 mmap_state, write_combine);
> +       vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
>
>         ret = remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
>                                vma->vm_end - vma->vm_start, vma->vm_page_prot);
>

Acked-by: Yinghai Lu <yinghai@kernel.org>

>
>
> commit 962972ee5e0ba6ceb680cb182bad65f8886586a6
> Author: Bjorn Helgaas <bhelgaas@google.com>
> Date:   Wed Jun 8 14:46:54 2016 -0500
>
>     PCI: Ignore write-combining when mapping I/O port space
>
>     PCI exposes files like /proc/bus/pci/00/00.0 in procfs.  These files
>     support operations like this:
>
>       ioctl(fd, PCIIOC_MMAP_IS_IO);           # request I/O port space
>       ioctl(fd, PCIIOC_WRITE_COMBINE, 1);     # request write-combining
>       mmap(fd, ...)
>
>     Many architectures don't allow mmap of I/O port space at all, but I don't
>     think it makes sense to do a write-combining mapping on the ones that do.
>     We could change proc_bus_pci_ioctl() so the user could never enable write-
>     combining for I/O port space, but that would break the following sequence,
>     which is currently legal:
>
>       mmap(fd, ...)                           # default is I/O, non-combining
>       ioctl(fd, PCIIOC_WRITE_COMBINE, 1);     # request write-combining
>       ioctl(fd, PCIIOC_MMAP_IS_MEM);          # request memory space
>       mmap(fd, ...)
>
>     Ignore the write-combining flag when mapping I/O port space.
>
>     Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
>
> diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
> index 3f155e7..21f8d613 100644
> --- a/drivers/pci/proc.c
> +++ b/drivers/pci/proc.c
> @@ -247,7 +247,8 @@ static int proc_bus_pci_mmap(struct file *file, struct vm_area_struct *vma)
>
>         ret = pci_mmap_page_range(dev, vma,
>                                   fpriv->mmap_state,
> -                                 fpriv->write_combine);
> +                                 (fpriv->mmap_state = pci_mmap_mem) ?
> +                                       fpriv->write_combine : 0);
>         if (ret < 0)
>                 return ret;
>

ok to me.

At the same time, can you kill __pci_mmap_set_pgprot() for powerpc.

diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 0f7a60f..0d0148d 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -356,36 +356,6 @@ static struct resource
*__pci_mmap_make_offset(struct pci_dev *dev,
 }

 /*
- * Set vm_page_prot of VMA, as appropriate for this architecture, for a pci
- * device mapping.
- */
-static pgprot_t __pci_mmap_set_pgprot(struct pci_dev *dev, struct resource *rp,
-                      pgprot_t protection,
-                      enum pci_mmap_state mmap_state,
-                      int write_combine)
-{
-
-    /* Write combine is always 0 on non-memory space mappings. On
-     * memory space, if the user didn't pass 1, we check for a
-     * "prefetchable" resource. This is a bit hackish, but we use
-     * this to workaround the inability of /sysfs to provide a write
-     * combine bit
-     */
-    if (mmap_state != pci_mmap_mem)
-        write_combine = 0;
-    else if (write_combine = 0) {
-        if (rp->flags & IORESOURCE_PREFETCH)
-            write_combine = 1;
-    }
-
-    /* XXX would be nice to have a way to ask for write-through */
-    if (write_combine)
-        return pgprot_noncached_wc(protection);
-    else
-        return pgprot_noncached(protection);
-}
-
-/*
  * This one is used by /dev/mem and fbdev who have no clue about the
  * PCI device, it tries to find the PCI device first and calls the
  * above routine
@@ -458,9 +428,10 @@ int pci_mmap_page_range(struct pci_dev *dev,
struct vm_area_struct *vma,
         return -EINVAL;

     vma->vm_pgoff = offset >> PAGE_SHIFT;
-    vma->vm_page_prot = __pci_mmap_set_pgprot(dev, rp,
-                          vma->vm_page_prot,
-                          mmap_state, write_combine);
+    if (write_combine)
+        vma->vm_page_prot = pgprot_noncached_wc(protection);
+    else
+        vma->vm_page_prot = pgprot_noncached(protection);

     ret = remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
                    vma->vm_end - vma->vm_start, vma->vm_page_prot);
