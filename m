From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Mon, 10 Jan 2005 07:54:36 +0000
Subject: Re: [PATCH] ia64: reset console_loglevel so INIT output always goes to console
Message-Id: <200501100754.j0A7saBi001370@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105140871.25267.50.camel@eeyore>
In-Reply-To: <1105140871.25267.50.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Russ Anderson <rja@sgi.com> wrote:
> >For example, having SAL rendezvous all the CPUs before calling OS_MCA 
> >may have been reasonable when linux lacked the ability to recover from 
> >an MCA.  But now that is changing, the descision to rendezvous CPUs
> >should get made later, in linux, if it cannot recover from the MCA.
> >Does it really make sense to rendezvous 512 CPUs just because one
> >CPU happened to hit a memory uncorrectable in a user application
> >(and recovers by killing the appication and discarding the page)?
> 
> I do not see any alternative.  SAL has no idea if the OS can recover
> from a memory MCA or not, that decision has to be made by the OS.
> Leaving the rendezvous decision to the OS would significantly
> complicate the OS/SAL interface, it requires another SAL call by the
> OS, changes to every SAL version and code in the OS to work out if the
> current prom supports the SAL change or not.  If memory is failing, we
> want the other cpus to keep off that physical memory while we work
> around the problem and decide if we can recover, so we need to stop the
> other cpus anyway.

I agree with Keith. Although it might seem a bit of an overkill to
rendezvous all CPUs on large systems, I think it greatly enhances the
chances of a clean recovery. Based on my error handing experience 
on MIPS based systems with similar CPU counts, you still might have external 
interventions etc.

Getting the system into a known state for the rare recovery case is
certainly a big advantage and avoids a lot of corner cases which will
be extremly hard to test. 

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

