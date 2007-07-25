From: Horms <horms@verge.net.au>
Date: Wed, 25 Jul 2007 13:37:01 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <20070725133700.GA4462@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 25, 2007 at 05:59:22PM +0900, Kenji Kaneshige wrote:
> Doug,
> 
> 2007-07-25 (水) の 01:09 -0400 に Doug Chapman さんは書きました:
> > Yasuaki,
> > 
> > I added a bunch of printk's to try to better understand this.
> > ia64_mv.setup does get initialized properly but then gets overwritten.
> > It appears that it gets overwritten in __bind_irq_vector but I have not
> > narrowed down exactly where.  I put a printk at the top and bottom of
> > this function to show what ia64_mv.setup is and I am finding that on the
> > 3rd call to this function it causes ia64_mv.setup to get set to -1.
> > 
> > It is getting way too late for me (1AM here).  I will try to dig into
> > this more tomorrow but at least I have narrowed it down to a bit of code
> > that actually is touched by the commit that causes the panic.
> > 
> > - Doug
> 
> I found a bug which causes wrong access to vector_table[] array.
> I guess ia64_mv.setup was destroyed by this. Could you try the
> attached patch?

I was also seeing a strange problem relating to the
vector domain patch which seemed to be causing
corruption of vectors_in_migration, which caused migrate_irqs()
to emmit suprious IRQ errors (when called by kexec).

I'll try and confirm that this patch soles the problem that
I was seeing tomorrow.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

