From: grundler@cup.hp.com (Grant Grundler)
Date: Wed, 09 Apr 2003 06:20:46 +0000
Subject: Re: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writin
Message-Id: <marc-linux-ia64-105590723705446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 09, 2003 at 01:36:33AM -0400, Mike Fox wrote:
>   /*
>    * this maps the physical memory to the user
>    */
>   if (remap_page_range(vma->vm_start, offset, vma->vm_end-vma->vm_start,
>                             vma->vm_page_prot))
>   {
>     return -EAGAIN;
>   }

The example code I posted (a) used physical addresses and (b)
assume the "user" was root (to access /dev/mem/).

XFree86 pokes around in PCI MMIO and IO space and does work.
Have you tried to dig through the source of XF86 4.2?

Have you checked the return address (to user space) is uncached?
If I understood details of VM it might be obvious from the code
you posted.

hth,
grant

> 
> Thanks,
> Mike.
> 
> 
> 
> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org [mailto:linux-ia64-admin@linuxia64.org]
> On Behalf Of Grant Grundler
> Sent: Tuesday, April 08, 2003 8:43 PM
> To: Mike Fox
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] mmap crashes system after mapping PCI device into
> user space and reading and writing.
> 
> On Tue, Apr 08, 2003 at 05:59:56PM -0400, Mike Fox wrote:
> ...
> > Has anyone tried using mmap to remap PCI device memory into user space?  I
> > have seen the following problem:  If I do the mmap, it returns
> successfully,
> > and I can indeed access the device memory.  Unfortunately, the system will
> > hang within about a minute after doing so.
> ...
> 
> David Mosberger passed on a very short program who's essence is:
>   mem = mmap (NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd,
> offset);
>   if (mem = MAP_FAILED)
>   {
>     perror ("memmap");
>     exit (-1);
>   }
> 
> This works on the HP ZX1 platforms with 2.4.20+patches kernel.
> 
> Be warned, it's *very* easy to crash a machine when using /dev/mem
> and scribbling in misc parts of IO space. The symptom will typically
> be an MCA (see "errdump MCA" output from EFI to get the xip).
> 
> grant
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Grant Grundler                           Linux Open Systems Lab/BCST
grundler@cup.hp.com                      +1.408.447.7253

