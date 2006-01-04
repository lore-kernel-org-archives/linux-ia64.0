From: Greg KH <gregkh@suse.de>
Date: Wed, 04 Jan 2006 00:27:38 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <20060104002737.GA18963@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222201651.2019.37913.96422@lnx-maule.americas.sgi.com> <20051222201657.2019.69251.48815@lnx-maule.americas.sgi.com> <20060103223918.GB13841@esmail.cup.hp.com> <20060103235024.GC16827@sgi.com> <20060104002047.GA14810@esmail.cup.hp.com>
In-Reply-To: <20060104002047.GA14810@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Mark Maule <maule@sgi.com>, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Tue, Jan 03, 2006 at 04:20:47PM -0800, Grant Grundler wrote:
> On Tue, Jan 03, 2006 at 05:50:24PM -0600, Mark Maule wrote:
> > > > +struct msi_ops msi_apic_ops = {
> > > > +	.setup = msi_setup_apic,
> > > > +	.teardown = msi_teardown_apic,
> > > > +#ifdef CONFIG_SMP
> > > > +	.target = msi_target_apic,
> > > > +#endif
> > > 
> > > Mark,
> > > msi_target_apic() initializes address_lo parameter.
> > > Even on a UP machine, we need inialize this value.
> > 
> > Not sure what you mean here.  target is used to retarget an existing
> > MSI vector to a different processor.
> 
> Right - I didn't realize the caller, set_msi_affinity(), was surrounded by
> "#ifdef CONFIG_SMP".
> 
> But set_msi_affinity() appears to be dead code.
> I couldn't find any calls to set_msi_affinity() in 2.6.14 or 2.6.15.
> Greg, you want a patch to remove that?

Yes please, that would be great to have.

thanks,

greg k-h
