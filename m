From: "Mike Fox" <mfox@annapmicro.com>
Date: Wed, 09 Apr 2003 23:53:38 +0000
Subject: RE: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writin
Message-Id: <marc-linux-ia64-105590723705452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hey all, I got it working! I was porting this code from a 32 bit version,
and it was as follows:

  /*
   * Accessing memory above the top the kernel knows about or
   * through a file pointer that was marked O_SYNC will be
   * done non-cached.
   *
   * Set VM_IO, as this is likely a non-cached access to an
   * I/O area, and we don't want to include that in a core
   * file.
   */
  if (offset >= __pa(high_memory) || (file->f_flags & O_SYNC))
  {
     vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
     vma->vm_flags |= VM_IO;
  }

Turns out my pgprot_noncached was not getting called, so I took it out of
the conditional. Thanks for all of your help.

I just started working at my current company 3 weeks ago, but it looks like
we will be doing a lot of work in the Linux environment on 32 and 64 bit
architectures.

I went ahead and bought the book, "ia-64 linux kernel", by David Mosberger
and Stephane Eranian. My background is in EE, and I never got a chance to
take an OS class, but I figure this book is my chance.

Thanks again,
Mike Fox.


-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
Sent: Wednesday, April 09, 2003 1:46 PM
To: mfox@annapmicro.com
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] mmap crashes system after mapping PCI device into
user space and reading and writing.

>>>>> On Wed, 9 Apr 2003 01:36:33 -0400, "Mike Fox" <mfox@annapmicro.com>
said:

  Mike> In the driver I am basically doing this in my mmap entry point:

  Mike>   vma-> vm_page_prot = pgprot_noncached(vma->vm_page_prot);
  Mike>   vma-> vm_flags |= VM_IO;

  Mike> /*
  Mike> * this maps the physical memory to the user
  Mike> */
  Mike> if (remap_page_range(vma->vm_start, offset,
vma->vm_end-vma->vm_start, vma->vm_page_prot))
  Mike> {
  Mike>     return -EAGAIN;
  Mike> }

This is basically what drivers/char/mem.c is doing, so there is
nothing obviously wrong here.

	--david


