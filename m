From: Horms <horms@verge.net.au>
Date: Wed, 15 Feb 2006 02:10:57 +0000
Subject: Re: [Patch]IA64 kexec
Message-Id: <20060215021055.GA13726@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131406068.2524.15.camel@linux-znh>
In-Reply-To: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 14, 2006 at 04:13:07PM +1100, Keith Owens wrote:
> Horms (on Tue, 14 Feb 2006 13:06:44 +0900) wrote:
> >
> >I sense pain. Looking over the code - very naievely - would it be
> >possible to register an alternate INIT handler when kexecing.
> 
> Not a good idea, the INIT handler code is very closely tied to the
> SAL/OS interface.  But what kexec can do is to register itself on the
> notify_die() chain, it will get called for multiple events including
> DIE_INIT_SLAVE_ENTER, DIE_INIT_SLAVE_PROCESS, DIE_INIT_SLAVE_LEAVE,
> DIE_INIT_MONARCH_ENTER, DIE_INIT_MONARCH_PROCESS and
> DIE_INIT_MONARCH_LEAVE.  That chain and the associated events is meant
> for debuggers, crash dumpers and assorted RAS tools.  See also the
> DIE_MCA_* events on the same chain.

Thanks, that looks quite promising indeed. However, after poking round a
bit more I'm a little confused about what the intent of using INIT is.

Is the idea to intercept an INIT, produced by the front panel, a
maintenence processor, (or perhaps an internal error), and then start
kexecing? Or is the idea for kexec to use INIT internally to halt the
processors.

In the case of the latter, which is what I have been thinking of up to
now, does anyone have pointers as to how kexec might produce an INIT?
I've spend a bit of time hunting through Intel documentation to no
avail, other than that perhaps the BMC could do the trick (via IPMI?). 

Lastly, if INIT is being used to shut off the processors by kexec, is it
reasonable to assume that an INIT will hit all processors, and thus the
slave processors can halt themselves in the callback (using cpu_die()?).
Or is it better to only watch for a monarch norifier, and have it kill
off the slave CPUs somehow.

-- 
Horms
