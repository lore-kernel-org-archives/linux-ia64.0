From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Jun 2003 17:36:57 +0000
Subject: Re: [Linux-ia64] heads up: i/o mmu related changes
Message-Id: <marc-linux-ia64-105590723706203@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706202@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706202@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 10 Jun 2003 01:07:18 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> I justed checked in a changeset
  David> (davidm@tiger.hpl.hp.com|ChangeSet|20030610070955|57077) to
  David> make the kernel work better for machines with I/O MMU.  This
  David> should fix the long-standing bug where IDE disks on machines
  David> with memory above 4GB would MCA if the machine has an I/O
  David> MMU.

  David> The trick was to make PCI_DMA_BUS_IS_PHYS a variable which is
  David> set at runtime.  Machines with I/O MMUs or machines with PCI
  David> buses which live in separate address spaces MUST clear this
  David> variable.  I updated the code for the zx1 I/O MMU.  I didn't
  David> touch the SGI I/O MMU code, though, as I wouldn't be able to
  David> test it.

Actually, you may want to hold off on this one.  I think I'll need to
fine-tune this a bit more.  My current thinking is that we need a
variable ia64_max_iommu_page_size or something like that, which will
tell us what to set BIO_VMERGE_BOUNDARY to.

	--david

