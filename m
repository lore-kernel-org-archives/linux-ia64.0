From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Apr 2003 17:45:45 +0000
Subject: RE: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writin
Message-Id: <marc-linux-ia64-105590723705449@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Apr 2003 01:36:33 -0400, "Mike Fox" <mfox@annapmicro.com> said:

  Mike> In the driver I am basically doing this in my mmap entry point:

  Mike>   vma-> vm_page_prot = pgprot_noncached(vma->vm_page_prot);
  Mike>   vma-> vm_flags |= VM_IO;

  Mike> /*
  Mike> * this maps the physical memory to the user
  Mike> */
  Mike> if (remap_page_range(vma->vm_start, offset, vma->vm_end-vma->vm_start, vma->vm_page_prot))
  Mike> {
  Mike>     return -EAGAIN;
  Mike> }

This is basically what drivers/char/mem.c is doing, so there is
nothing obviously wrong here.

	--david

