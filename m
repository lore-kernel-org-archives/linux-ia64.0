From: Jack Steiner <steiner@sgi.com>
Date: Mon, 09 Oct 2006 15:09:22 +0000
Subject: Re: Sending cpu 0 back to SAL slave loop
Message-Id: <20061009150922.GB26250@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061006203909.GA6500@sgi.com>
In-Reply-To: <20061006203909.GA6500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Oct 08, 2006 at 05:37:04PM +1000, Keith Owens wrote:
> Matthew Wilcox (on Fri, 6 Oct 2006 14:44:43 -0600) wrote:
> >On Fri, Oct 06, 2006 at 03:39:10PM -0500, Jack Steiner wrote:
> >> For kexec, it is ESSENTIAL that all cpus except for the one doing
> >> the kexec be returned to the SAL slave loop. If this is not done, our
> >> chipset will misdirect IO interrupts on the newly exec'ed kernel.
> >
> >Could you do an IPI call to have CPU 0 do the kexec and have the CPU
> >that sent the IPI fall into the SAL slave loop instead?
> 
> An IPI call will not work for MCA or INIT.  Both of those drive all
> cpus into a state which has disabled interrupts.

We could modify mca.c so that slave cpus are brought out of the mca spin
loop and sent back to the SAL slave loop.  Changes would be required to
the places in mca.c that spin on: 

	while (monarch_cpu != -1)
		cpu_relax();


However, I don't think I like this approach. We should try to drive all
cpus (except for the one doing the kexec) back to the SAL slave loop.
Unfortunately, this will not be successful in all cases - especially ones
where the system has experienced a hardware failure.

We need to modify our PROM so that we can detect a kexec of a new kernel.
At the time of the kexec, cpus not in the slave loop cannot be the target
for future interrupts. I think this can be done. 


-- jack

