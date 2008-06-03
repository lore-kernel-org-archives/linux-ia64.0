From: Russ Anderson <rja@sgi.com>
Date: Tue, 03 Jun 2008 16:19:35 +0000
Subject: Re: [patch] fix bootmem regression on Altix
Message-Id: <20080603161935.GA20365@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080424181659.GB5211@sgi.com>
In-Reply-To: <20080424181659.GB5211@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 03, 2008 at 10:56:10AM +0200, Petr Tesarik wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Russ Anderson wrote:
> > [patch] fix bootmem regression on Altix
> > 
> > A recent change prevents SGI Altix from booting.
> > This patch fixes the problem.
> > 
> > The regresson was introduced in commit 434d53b00d6bb7be0a1d3dcc0d0d5df6c042e164
> 
> Could we get this into mainline?

Which mainline tree?  Tony pushed the patch to Linus back on 4/24
and I see it in Linus' tree.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;hG2613b961affef0c73f1c797993678312e7c666


>                                    My Altix box won't boot without this
> patch either and applying it on top of all trees after the
> above-mentioned commit is annoying when bisecting. :(
> 
> Anyway, thank you for your patch, Russ!
> 
> Petr Tesarik
> 
> > Signed-off-by: Russ Anderson (rja@sgi.com)
> > 
> > ---
> >  kernel/sched.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > Index: test/kernel/sched.c
> > =================================> > --- test.orig/kernel/sched.c	2008-04-23 16:00:58.000000000 -0500
> > +++ test/kernel/sched.c	2008-04-23 16:01:33.047453963 -0500
> > @@ -8127,7 +8127,7 @@ void __init sched_init(void)
> >  	 * we use alloc_bootmem().
> >  	 */
> >  	if (alloc_size) {
> > -		ptr = (unsigned long)alloc_bootmem_low(alloc_size);
> > +		ptr = (unsigned long)alloc_bootmem(alloc_size);
> >  
> >  #ifdef CONFIG_FAIR_GROUP_SCHED
> >  		init_task_group.se = (struct sched_entity **)ptr;
> 
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.6 (GNU/Linux)
> Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org
> 
> iD8DBQFIRQcqjpY2ODFi2ogRArSnAKCLqsJldLKNMWKgA5KFB2K1S0kOoQCeKRe4
> ARtwQ/mpL0BrFVo+h2IpdJQ> =vvtw
> -----END PGP SIGNATURE-----

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
