From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 13 Oct 2006 00:50:50 +0000
Subject: RE: [RFC] Variable Kernel Page size support
Message-Id: <000501c6ee61$a11df010$db34030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, October 12, 2006 5:33 PM
> IA64: Variable Kernel Page size support
> 
> This patch adds the capability to manage pages of varying sizes for the
> kernel in region 7. This is done by setting special bits in bits 54 to 60.
> 
> 54-59 Page size.
> 
> If set then the default pagesize of region 7 is overridden on a fault
> and a TLB of the requested size is inserted. This may be used to
> manually control the coverage of a single TLB. A macro SET_TLB_SIZE
> is provide that can be used upon a kernel address to encode the
> desired page size. Code must refer to the address range through
> this address in order to get the desired TLB size.
> 
> 60 Page table enable.

This is just getting better and better :-)) nifty!


> If set then a lookup is performed using the region7_pgdir table.
> That table is segmented into 8 section for the varying page
> sizes supported.

What is the reason to anchor these 8 sections with pgdir?  Can't we just
extract page size directly from the virtual address? Chop off bit 54 - 60,
that's the physical address, whola.  I don't see why it can't be done.
