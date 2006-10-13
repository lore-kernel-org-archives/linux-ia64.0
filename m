From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 01:38:41 +0000
Subject: RE: [RFC] Variable Kernel Page size support
Message-Id: <Pine.LNX.4.64.0610121834350.23131@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Oct 2006, Chen, Kenneth W wrote:

> Christoph Lameter wrote on Thursday, October 12, 2006 5:33 PM
> > If set then a lookup is performed using the region7_pgdir table.
> > That table is segmented into 8 section for the varying page
> > sizes supported.
> > 
> > 0 = _PAGE_SIZE_64K
> > 1 = _PAGE_SIZE_256K
> > 2 = _PAGE_SIZE_1M
> > 3 = _PAGE_SIZE_4M
> > 4 = _PAGE_SIZE_16M
> > 5 = _PAGE_SIZE_64M
> > 6 = _PAGE_SIZE_256M and _PAGE_SIZE_4K and _PAGE_SIZE_8K
> > 7 = _PAGE_SIZE_1G and PAGE_SIZE_16k
> 
> Another thing cross my mind is that this is in region 7, and effectively
> vhpt is disabled for those sections of virtual address.  I suppose the
> larger page size will win back the loss from not using vhpt.  And this
> trade off also depends on data access pattern.  Some of the small page
> size will take  double hit on (1) being very small and (2) not having
> vhpt to mitigate tlb miss latency.  You might want to just drop those
> small sizes.

You are right. If someone would like to use smaller pages then he could 
just use vmalloc. There is no hardcoded support for these sizes in the 
patch. In order to "drop" these sizes we would only have to 
change the above comments and remove the mentioning of 4k, 8k and 16k. 
And then there would be no longer any possible conflicts.





