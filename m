From: Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de>
Date: Wed, 09 Apr 2003 08:57:12 +0000
Subject: Re: [Linux-ia64] mmap crashes system after mapping PCI device into user
Message-Id: <marc-linux-ia64-105590723705447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Mike Fox schrieb:
> 
> 
> In the driver I am basically doing this in my mmap entry point:
> 
>   vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
>   vma->vm_flags |= VM_IO;

i know this is ugly stuff, but ...
maybe you want to try this instead of the above:

#if defined(__ia64__)
	vmap->vm_flags |= (VM_SHM | VM_LOCKED | VM_IO);
	vmap->vm_flags &= ~(VM_SHARED | VM_MAYSHARE);
	vmap->vm_page_prot = __pgprot(pgprot_val(vmap->vm_page_prot)& ~_PAGE_AR_RW);
#endif

> 
> Thanks,
> Mike.
> 

 christian

