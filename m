From: akepner@sgi.com
Date: Wed, 22 Aug 2007 15:54:30 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <20070822155430.GO5592@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com> <46C94FD5.6000006@sgi.com> <20070821193522.GD5592@sgi.com> <20070821130515.6e745b17.randy.dunlap@oracle.com> <1187729729.18410.48.camel@localhost.localdomain> <20070822003450.GM5592@sgi.com> <1187745249.18410.67.camel@localhost.localdomain>
In-Reply-To: <1187745249.18410.67.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Jes Sorensen <jes@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

On Tue, Aug 21, 2007 at 08:14:09PM -0500, James Bottomley wrote:
> On Tue, 2007-08-21 at 17:34 -0700, akepner@sgi.com wrote:
> .....
> > On Altix, DMA from a device isn't guaranteed to arrive in host memory 
> > in the order it was sent from the device. This reordering can happen 
> > in the NUMA interconnect (it's specifically not a PCI reordering.)
> 
> This is mmiowb and read_relaxed() again, isn't it?
> .....

No, this is different. 

This problem here has do with ordering writes from the device 
to host memory. Specifically this problem can be manifested with 
Infiniband - when a Completion Queue Entry is written by the IB 
device, it indicates that data is available in host memory. But 
the write to the Completion Queue can race with DMA of data. 

(Completion Queues can be allocated by the kernel or in userspace. 
The race described above can only happen when they are allocated 
in userspace - kernel allocations of CQs use dma_alloc_coherent() 
and so get the "barrier" attribute that's needed to prevent the 
race. The proposed new interface would allow CQs, or anything else, 
allocated with plain old malloc(), to set the barrier attribute.)

-- 
Arthur

