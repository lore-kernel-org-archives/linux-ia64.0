From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 26 Jun 2007 06:51:03 +0000
Subject: Re: [PATCH 3/3] Make jprobes a little safer for users
Message-Id: <20070625235103.2d8dea18.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
	<7a070581b2fe53ea65216e86c86abc4f40464341.1182822366.git.michael@ellerman.id.au>
	<20070626055347.GB6841@lst.de>
	<1182837838.6673.17.camel@concordia.ozlabs.ibm.com>
In-Reply-To: <1182837838.6673.17.camel@concordia.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: michael@ellerman.id.au
Cc: Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, anil.s.keshavamurthy@intel.com, ananth@in.ibm.com

On Tue, 26 Jun 2007 16:03:58 +1000 Michael Ellerman <michael@ellerman.id.au> wrote:

> On Tue, 2007-06-26 at 07:53 +0200, Christoph Hellwig wrote:
> > On Tue, Jun 26, 2007 at 11:48:51AM +1000, Michael Ellerman wrote:
> > > I realise jprobes are a razor-blades-included type of interface, but
> > > that doesn't mean we can't try and make them safer to use. This guy I
> > > know once wrote code like this:
> > > 
> > > struct jprobe jp = { .kp.symbol_name = "foo", .entry = "jprobe_foo" };
> > > 
> > > And then his kernel exploded. Oops.
> > > 
> > > This patch adds an arch hook, arch_deref_entry_point() (I don't like it either)
> > > which takes the void * in a struct jprobe, and gives back the text address
> > > that it represents.
> > > 
> > > We can then use that in register_jprobe() to check that the entry point
> > > we're passed is actually in the kernel text, rather than just some random
> > > value.
> > 
> > Please don't add more weak functions, they're utterly horrible for
> > anyone trying to understand the code.  Otherwise this looks fine to me.
> 
> What do you recommend instead? #define ARCH_HAS_FOO_BAR ?

o lord, save us, no.

> I don't see what's utterly horrible about them.

Me either.

> The fact that they're
> weak is fairly reasonable documentation that they're overridden
> somewhere else. And grep/cscope/ctags will find both the weak and
> non-weak versions for you?

yup.

In this case we could just require that each jprobes-supporting
architecture implement arch_deref_entry_point().


Or one could do the Linus trick.  In each architecture which implements
arch_deref_entry_point() do:

#define arch_deref_entry_point arch_deref_entry_point

in the per-arch header file then, in non-arch code, do

#ifndef arch_deref_entry_point
static unsigned long arch_deref_entry_point(...)
{
	<generic implementation>
}
#endif

That's just the ARCH_HAS_FOO_BAR thing, only less fugly.
