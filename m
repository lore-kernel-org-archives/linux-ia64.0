From: Grant Grundler <iod00d@hp.com>
Date: Fri, 22 Oct 2004 01:01:50 +0000
Subject: Re: [PATCH] I/O space write barrier
Message-Id: <20041022010150.GH3878@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410211613.19601.jbarnes@engr.sgi.com>
In-Reply-To: <200410211613.19601.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Thu, Oct 21, 2004 at 04:13:19PM -0700, Jesse Barnes wrote:
> This patch adds a mmiowb() call to deal with this sort of situation, and 
> adds some documentation describing I/O ordering issues to deviceiobook.tmpl.  

Jesse,
This looks overall pretty good. Just a few nits.

> The idea is to mirror the regular, cacheable memory barrier operation, wmb.  
> Example of the problem this new macro solves:
> 
> CPU A:  spin_lock_irqsave(&dev_lock, flags)
> CPU A:  ...
> CPU A:  writel(newval, ring_ptr);
> CPU A:  spin_unlock_irqrestore(&dev_lock, flags)
>         ...
> CPU B:  spin_lock_irqsave(&dev_lock, flags)
> CPU B:  writel(newval2, ring_ptr);
> CPU B:  ...
> CPU B:  spin_unlock_irqrestore(&dev_lock, flags)
> 
> In this case, newval2 could be written to ring_ptr before newval.  Fixing it 
> is easy though:
> 
> CPU A:  spin_lock_irqsave(&dev_lock, flags)
> CPU A:  ...
> CPU A:  writel(newval, ring_ptr);
> CPU A:  mmiowb(); /* ensure no other writes beat us to the device */
> CPU A:  spin_unlock_irqrestore(&dev_lock, flags)
>         ...
> CPU B:  spin_lock_irqsave(&dev_lock, flags)
> CPU B:  writel(newval2, ring_ptr);
> CPU B:  ...
> CPU B:  mmiowb();
> CPU B:  spin_unlock_irqrestore(&dev_lock, flags)

This is a great example and should be used instead of the qla1280 code
snippet that you used. Please just point at the source file that contains
the code and name the register usage this example represents.
Ie make it easy to find the example in real code without using
line numbers.

> I've tried to describe how mmiowb() differs from PCI posted 
> write flushing in the patch to deviceiobook.tmpl.

Yes - I think this is alot clearer than the previous documents - thanks!

...
> +<programlisting>
> +       sp->flags |= SRB_SENT;
> +       ha->actthreads++;
> +       WRT_REG_WORD(&amp;reg->mailbox4, ha->req_ring_index);
> +
> +       /*
> +        * A Memory Mapped I/O Write Barrier is needed to ensure that this write
> +        * of the request queue in register is ordered ahead of writes issued
> +        * after this one by other CPUs.  Access to the register is protected
> +        * by the host_lock.  Without the mmiowb, however, it is possible for
> +        * this CPU to release the host lock, another CPU acquire the host lock,
> +        * and write to the request queue in, and have the second write make it
> +        * to the chip first.
> +        */
> +       mmiowb(); /* posted write ordering */
> +</programlisting>

This is the example code I'd like to see replaced with your
synthetic example above.


thanks,
grant
