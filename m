From: Doug Chapman <doug.chapman@hp.com>
Date: Mon, 23 Jul 2007 22:24:45 +0000
Subject: RE: Linus' tree broken?
Message-Id: <1185229485.7158.49.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-07-23 at 13:42 -0700, Luck, Tony wrote:
> > > Could be, but it sounds like there's something fishy in the current
> > > tree - Doug Chapman is having problems as well, presumably on zx1 boxes.
> >
> > I am seeing the panic on HP zx1 and zx2 systems.  Currently doing a git
> > bisect to narrow it down.
> 
> 2.6.23-rc1 booted OK on my rx2620.  On the zx2000 too (though X is currently
> behaving weirdly, I think that might be some other issue though).
> 
> -Tony

Odd,

I am hitting this on my rx2620, rx6600 and rx2600 (i.e. everywhere I
have tried it) and the bisection is showing that it appears to have been
broken before -rc1.


It appears to have something to do with grabbing the kernel args.  The
panic happens here:

0xa0000001007f1511 is in setup_arch (arch/ia64/kernel/setup.c:570).
565
566             /* enable IA-64 Machine Check Abort Handling unless disabled
*/
567             if (!nomca)
568                     ia64_mca_init();
569
570             platform_setup(cmdline_p);
571             paging_init();
572     }


If it is working for others I am wondering if the version of elilo makes
a difference.  I am using RHEL5 as my base system.  I might try grabbing
elilo from upstream or from another release and see if that makes a
difference.

Bisection almost done, should know what commit triggered this soon.  I
tried reverting a couple seemingly obvious patches but didn't find it
that way.

- Doug


