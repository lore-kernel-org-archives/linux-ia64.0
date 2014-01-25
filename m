From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Sat, 25 Jan 2014 17:51:27 +0000
Subject: Re: [PATCH 0/5] ia64 ski emulator patches
Message-Id: <21219.63903.326798.277717@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com>
	<21218.28095.779306.523187@gargle.gargle.HOWL>
	<alpine.LRH.2.02.1401240937020.28468@file01.intranet.prod.int.rdu2.redhat.com>
In-Reply-To: <alpine.LRH.2.02.1401240937020.28468@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Mikulas Patocka writes:
 > 
 > 
 > On Fri, 24 Jan 2014, Mikael Pettersson wrote:
 > 
 > > Mikulas Patocka writes:
 > >  > Hi
 > >  > 
 > >  > Here I'm sending some ia64 patches to make it work in the ski emulator. 
 > >  > This has been broken for a long time.
 > > 
 > > Thanks.  I've recently started running 3.x kernels on ia64 via ski,
 > > but I'm getting random kernel crashes with 3.13.  I'll give your
 > > patches a try shortly.
 > 
 > I also had some random page-table corruption when running recent kernels 
 > in ski. The problems occured when upgrading the whole Debian distribution. 
 > Kernel 2.6.8 was solid, new kernels caused problems, I don't know why.

What I've seen so far seems to indicate that gcc-4.8.2 miscompiles ski,
resulting in kernel oopses, and _possibly_ that gcc-4.7.3 miscompiles
the kernel.  Ski compiled by gcc-4.7.3 (on x86_64) running a kernel
compiled by gcc-4.3.6 seems to be a solid combination for me.

 > > I've written a few patches to improve other aspects of running the
 > > kernel on ski:
 > > - ski patch to use tun/tap networking (no need to run ski as root)
 > > - ski patch to implement a fixed-frequency ITC (the ITC is currently
 > >   highly variable, completely breaking basic timekeeping)
 > > - kernel patch to turn PAL_HALT_LIGHT into a new SSC_HALT_LIGHT,
 > >   and a corresponing ski patch to pause() on SSC_HALT_LIGHT; this
 > >   together with the fixed-frequency ITC patch allows ski to idle
 > >   with very low host CPU overhead when the guest kernel idles
 > > - kernel patch to bump the RAM size from 130MB to 2GB
 > > 
 > > I'd be happy to share these patches if there's interest in them.
 > > 
 > > /Mikael
 > 
 > I would be interested in them. I also patched that timekeeping issue in 
 > ski.

My ski patches are in <http://user.it.uu.se/~mikpe/linux/patches/ia64/ski-1.3.2/>
for now.  I'll post the kernel patches to linux-ia64 @ vger in a few minutes.

/Mikael
