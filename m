From: Mark Maule <maule@sgi.com>
Date: Wed, 21 Dec 2005 19:17:41 +0000
Subject: Re: [PATCH 2/4] msi vector targeting abstractions
Message-Id: <20051221191741.GI9920@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051221184337.5003.85653.32527@attica.americas.sgi.com> <20051221184348.5003.7540.53186@attica.americas.sgi.com> <20051221185637.GA13210@infradead.org>
In-Reply-To: <20051221185637.GA13210@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Wed, Dec 21, 2005 at 06:56:37PM +0000, Christoph Hellwig wrote:
> On Wed, Dec 21, 2005 at 12:42:41PM -0600, Mark Maule wrote:
> > Abstract portions of the MSI core for platforms that do not use standard
> > APIC interrupt controllers.  This is implemented through a set of callouts
> > which default to current behavior, but which can be overridden by calling
> > msi_register_callouts() in the platform msi init code.
> 
> we tend to calls these _ops or _operations instead of _callouts.
> Also I'd suggest to not keep the generic ones where they are but
> in a separate file and let the existing plattforms calls msi_register()
> with the ops table for those.  This keeps the interface symmetric instead
> of favouring the first implementation.

ok.

> 
> > @@ -89,10 +91,25 @@
> >  }
> >  
> >  #ifdef CONFIG_SMP
> > +static void msi_target_generic(unsigned int vector,
> > +			       unsigned int dest_cpu,
> > +			       uint32_t *address_hi,	/* in/out */
> > +			       uint32_t *address_lo)	/* in/out */
> 
> Please try to use u32 instead of uint32_t everywhere.  Dito for other
> sizes and signed types.

ok.

> 
> > +{
> > +	struct msg_address address;
> > +
> > +	address.lo_address.value = *address_lo;
> > +	address.lo_address.value &= MSI_ADDRESS_DEST_ID_MASK;
> > +	address.lo_address.value |> > +		(cpu_physical_id(dest_cpu) << MSI_TARGET_CPU_SHIFT);
> > +
> > +	*address_lo = address.lo_address.value;
> > +}
> 
> Why do we need the full struct msg_address here?  What about just:
> 
> static void msi_target_apic(unsigned int vector, unsigned int dest_cpu,
> 			    u32 *address_hi, u32 *address_lo)
> {
> 	u32 addr = *address_lo;
> 
> 	addr &= MSI_ADDRESS_DEST_ID_MASK;
> 	addr |= (cpu_physical_id(dest_cpu) << MSI_TARGET_CPU_SHIFT);
> 
> 	*address_lo = addr;
> }

Right.


> 
> > +	(*msi_callouts.msi_teardown)(vector);
> > +
> 
> just
> 	msi_ops.teardown(vector);
> 

ok.
