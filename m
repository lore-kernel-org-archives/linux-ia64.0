From: Andrew Morton <akpm@osdl.org>
Date: Thu, 04 Nov 2004 04:47:06 +0000
Subject: Re: [PATCH] fix HPET time_interpolator registration
Message-Id: <20041103204706.1c85d30a.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411031024.43782.bjorn.helgaas@hp.com>
	<20041103185721.743d9317.akpm@osdl.org>
	<Pine.LNX.4.58.0411031951110.3414@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411031951110.3414@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: bjorn.helgaas@hp.com, Robert.Picco@hp.com, venkatesh.pallipadi@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Wed, 3 Nov 2004, Andrew Morton wrote:
> 
> > Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> > >
> > >  Fixup after mid-air collision between Christoph adding time_interpolator.mask,
> > >  and me removing a static time_interpolator struct from hpet.
> > >
> > >  Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> > >
> > >  === drivers/char/hpet.c 1.14 vs edited ==> > >  --- 1.14/drivers/char/hpet.c	2004-11-02 07:40:42 -07:00
> > >  +++ edited/drivers/char/hpet.c	2004-11-03 10:05:26 -07:00
> > >  @@ -712,6 +712,7 @@
> > >   	ti->addr = &hpetp->hp_hpet->hpet_mc;
> > >   	ti->frequency = hpet_time_div(hpets->hp_period);
> > >   	ti->drift = ti->frequency * HPET_DRIFT / 1000000;
> > >  +	ti->mask = 0xffffffffffffffffLL;
> > >
> > >   	hpetp->hp_interpolator = ti;
> > >   	register_time_interpolator(ti);
> > >
> >
> > ti->mask is u64, and on some architectures u64 is `long'.  Compilers might
> > whine about this.   I'll make it
> >
> > 	ti->mask = -1;
> >
> > which just works.
> 
> Hmmm... How do you then specify a 64 bit mask without running into issues
> with the compilers?

Well with 0xffffffff[ffffffff] it's easy: use -1 and sign extension.

The only problem I can see is if you want to propagate a bit pattern across
the scalar but you don't know its size.  Say 0x5a5a5a5a versus
0x5a5a5a5a5a5a5a5a.  But nobody ever wants to do that.


