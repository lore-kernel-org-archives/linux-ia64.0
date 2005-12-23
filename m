From: Mark Maule <maule@sgi.com>
Date: Fri, 23 Dec 2005 15:32:15 +0000
Subject: Re: [PATCH 0/3] msi abstractions and support for altix
Message-Id: <20051223153215.GA11935@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222201651.2019.37913.96422@lnx-maule.americas.sgi.com> <20051222202259.GA4959@suse.de> <20051222202627.GI17552@sgi.com> <20051222203415.GA28240@suse.de> <20051222203824.GJ17552@sgi.com> <20051222214446.GC14978@kroah.com>
In-Reply-To: <20051222214446.GC14978@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Greg KH <gregkh@suse.de>, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Thu, Dec 22, 2005 at 01:44:46PM -0800, Greg KH wrote:
> On Thu, Dec 22, 2005 at 02:38:24PM -0600, Mark Maule wrote:
> > On Thu, Dec 22, 2005 at 12:34:15PM -0800, Greg KH wrote:
> > > On Thu, Dec 22, 2005 at 02:26:27PM -0600, Mark Maule wrote:
> > > > On Thu, Dec 22, 2005 at 12:22:59PM -0800, Greg KH wrote:
> > > > > On Thu, Dec 22, 2005 at 02:15:44PM -0600, Mark Maule wrote:
> > > > > > Resend #2: including linuxppc64-dev and linux-pci as well as PCI maintainer
> > > > > 
> > > > > I'll wait for Resend #3 based on my previous comments before considering
> > > > > adding it to my kernel trees:)
> > > > > 
> > > > 
> > > > Resend #2 includes the correction to the irq_vector[] declaration, and I
> > > > responded to the question about setting irq_vector[0] if that's what you
> > > > mean ...
> > > 
> > > Sorry, but I missed that last response.  Why do you set the [0] value in
> > > a #ifdef now?
> > 
> > Because on ia64 IA64_FIRST_DEVICE_VECTOR and IA64_LAST_DEVICE_VECTOR
> > (from which MSI FIRST_DEVICE_VECTOR/LAST_DEVICE_VECTOR are derived) are not
> > constants.  The are now global variables (see change to asm-ia64/hw_irq.h)
> > to allow the platform to override them.  Altix uses a reduced range of
> > vectors for devices, and this change was necessary to make assign_irq_vector()
> > to work on altix.
> 
> I'm with Matthew on this one, that's not a real fix for this.  What
> would PPC64 do in this case?

Using the existing framework, wouldn't PPC just define it's own
assign_irq_vector and {FIRST,LAST}_DEVICE_VECTOR and handle it however it
wants under the covers?

I agree that this is not a great solution, but it's what the existing framework
allowed.  I'm willing to pursue a more general vector allocation scheme, but
I suspect that'll take some time.

Is this issue going to hold up forward progress of this patchset?  IMO, this
set is a major step in generalizing the MSI code and I think the vector
generalizing code would best be handled by a separate effort.

Mark

Mark
