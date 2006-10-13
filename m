From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 01:12:21 +0000
Subject: RE: [RFC] Variable Kernel Page size support
Message-Id: <Pine.LNX.4.64.0610121810160.23030@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Oct 2006, Chen, Kenneth W wrote:

> > If set then a lookup is performed using the region7_pgdir table.
> > That table is segmented into 8 section for the varying page
> > sizes supported.
> 
> What is the reason to anchor these 8 sections with pgdir?  Can't we just
> extract page size directly from the virtual address? Chop off bit 54 - 60,
> that's the physical address, whola.  I don't see why it can't be done.

Yes we are chopping off the page size from the virtual address. But we 
need a page table to get to the physical address. That is what 
region7_pgdir is for. And it has different sections because that enables 
concurrent use of various page sizes in region 7. If pages with multiple 
page sizes would be in the same page table then we would have strange 
page number overlap scenarios to deal with.

