From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Aug 2018 23:45:43 +0000
Subject: Re: [PATCH 10/20] powerpc/dma-noncoherent: don't disable irqs over kmap_atomic
Message-Id: <a1a258002571aca84fd884ccfa7ec9e84ff0b051.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-11-hch@lst.de>
 <bfa22816fee0759cfee28705b427be3586c7d2e3.camel@kernel.crashing.org>
 <20180822070241.GD19284@lst.de>
In-Reply-To: <20180822070241.GD19284@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Wed, 2018-08-22 at 09:02 +0200, Christoph Hellwig wrote:
> On Thu, Aug 09, 2018 at 10:27:46AM +1000, Benjamin Herrenschmidt wrote:
> > On Mon, 2018-07-30 at 18:38 +0200, Christoph Hellwig wrote:
> > > The requirement to disable local irqs over kmap_atomic is long gone,
> > > so remove those calls.
> > 
> > Really ? I'm trying to verify that and getting lost in a mess of macros
> > from hell in the per-cpu stuff but if you look at our implementation
> > of kmap_atomic_prot(), all it does is a preempt_disable(), and then
> > it uses kmap_atomic_idx_push():
> > 
> > 	int idx = __this_cpu_inc_return(__kmap_atomic_idx) - 1;
> > 
> > Note the use of __this_cpu_inc_return(), not this_cpu_inc_return(),
> > ie this is the non-interrupt safe version...
> 
> Looks like the powerpc variant indeed isn't save.
> 
> I did look a bit more through the code and history, and it seems
> like we remove the need to disable irqs when called from process
> context a while ago, but we still require disabling irqs when called
> from irq context.  Given that this code can also be called from
> irq context we'll have to keep the local_irq_save.

This is the same with x86 no ?

32-bit x86 kmap_atomic_prot is the same as ours...

In fact I wonder why the preempt_disable() in there since it needs to
be protected against interrupt ?

Or is it that we never actually call kmap_atomic_* these days from
interrupt, and the atomic versions are just about dealing with
spinlocks ?

Cheers,
Ben.
 
