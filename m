From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 13 Oct 2006 00:55:48 +0000
Subject: RE: [RFC] Variable Kernel Page size support
Message-Id: <000601c6ee62$52b70690$db34030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth wrote on Thursday, October 12, 2006 5:51 PM
> > If set then a lookup is performed using the region7_pgdir table.
> > That table is segmented into 8 section for the varying page
> > sizes supported.
> 
> What is the reason to anchor these 8 sections with pgdir?  Can't we just
> extract page size directly from the virtual address? Chop off bit 54 - 60,
> that's the physical address, whola.  I don't see why it can't be done.

For a very large contiguous virtual address space, I guess there is no way
to get around page table indirection.  Oh well.  Never mind.

- Ken
