From: Jack Steiner <steiner@sgi.com>
Date: Sat, 07 Oct 2006 02:16:59 +0000
Subject: Re: Sending cpu 0 back to SAL slave loop
Message-Id: <20061007021659.GA23895@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061006203909.GA6500@sgi.com>
In-Reply-To: <20061006203909.GA6500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 06, 2006 at 02:44:43PM -0600, Matthew Wilcox wrote:
> On Fri, Oct 06, 2006 at 03:39:10PM -0500, Jack Steiner wrote:
> > For kexec, it is ESSENTIAL that all cpus except for the one doing
> > the kexec be returned to the SAL slave loop. If this is not done, our
> > chipset will misdirect IO interrupts on the newly exec'ed kernel.
> 
> Could you do an IPI call to have CPU 0 do the kexec and have the CPU
> that sent the IPI fall into the SAL slave loop instead?

Yes, that seems ok, too. One endcase that must be covered is the
case where where 1) cpu >0 panics and, 2) cpu 0 is looping with interrupts
disabled - perhaps waiting on a lock held by the panic'ing cpu.
In this case, the panic'ing cpu must send an NMI interrupt to cpu 0
to cause it to do the kexec.  Not sure but I think this can be made to work.

Hmmmmm. Another case that is more difficult to handle is a failure
where an MCA has occurred & cpu 0 is in the SAL rendez slave loop.
Kexec will have to bring cpu out of the rendez slave loop & cause it
to kexec the new kernel. Is this possible???


I like the NMI approach for the general case where you are kexec'ing 
a new kernel - not a crashdump kernel. We have some dependencies on 
the boot cpu not changing.

-- jack
