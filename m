From: Ingo Molnar <mingo@kernel.org>
Date: Thu, 26 Jul 2012 12:01:22 +0000
Subject: Re: [PATCH] debug: Do not permit CONFIG_DEBUG_STACK_USAGE=y on IA64 or PARISC
Message-Id: <20120726120122.GA24672@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4a613b26cc402fb3ed8130cd07a37e76f4c133ef.1342634029.git.tony.luck@intel.com>
 <20120725074501.GB27950@gmail.com>
 <1343203348.3139.16.camel@dabdike>
In-Reply-To: <1343203348.3139.16.camel@dabdike>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Helge Deller <deller@gmx.de>, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


* James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> On Wed, 2012-07-25 at 09:45 +0200, Ingo Molnar wrote:
> > * Tony Luck <tony.luck@intel.com> wrote:
> > 
> > > The stack_not_used() function in <linux/sched.h> assumes that stacks
> > > grow downwards. This is not true on IA64 or PARISC, so this function
> > > would walk off in the wrong direction and into the weeds.
> > > 
> > > Found on IA64 because of a compilation failure with recursive dependencies
> > > on IA64_TASKSIZE and IA64_THREAD_INFO_SIZE.
> > > 
> > > Fixing the code is possible, but should be combined with other
> > > infrastructure additions to set up the "canary" at the end of the stack.
> > > 
> > > Reported-by: Fengguang Wu <fengguang.wu@intel.com> (failed allmodconfig build)
> > > Signed-off-by: Tony Luck <tony.luck@intel.com>
> > > ---
> > >  lib/Kconfig.debug | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> > > index ff5bdee..4a18650 100644
> > > --- a/lib/Kconfig.debug
> > > +++ b/lib/Kconfig.debug
> > > @@ -714,7 +714,7 @@ config STACKTRACE
> > >  
> > >  config DEBUG_STACK_USAGE
> > >  	bool "Stack utilization instrumentation"
> > > -	depends on DEBUG_KERNEL
> > > +	depends on DEBUG_KERNEL && !IA64 && !PARISC
> > 
> > The modern way of doing this is by adding an ARCH_SUPPORTS_ 
> > flag.
> 
> That's a bit daft, isn't it? [...]

It's generally more maintainable than a random list of 
architecture exclusions because every (old or new) architecture 
can just grep for ARCH_SUPPORTS_ pattern and see whether they 
support everything that others support.

The above exclusion list of architectures is much harder to find 
in a structured way.

> [...]  We'd have to add ARCH_SUPPORTS_ flags to about 25 
> separate architectures just to get it not supported on these 
> two.

That is one off overhead and it makes things easier to maintain 
going forward.

Anyway, that's the current upstream technique and it's been in 
place for years.

> Since the problem is an invalid assumption about how the stack 
> grows, why not just condition it on that.  We actually have a 
> config option for this: CONFIG_STACK_GROWSUP.  But for some 
> reason ia64 doesn't define this, why not, Tony?  It looks 
> deliberate because you have replaced a lot of
> 
> #ifdef CONFIG_STACK_GROWSUP
> 
> with
> 
> #if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
> 
> but not all of them.

Yes, that's another possible solution, assuming that it's really 
only about the up/down difference.

Thanks,

	Ingo
