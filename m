From: Bob Picco <bob.picco@hp.com>
Date: Wed, 28 Sep 2005 10:36:06 +0000
Subject: Re: [Lhms-devel] RE: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050928103606.GB25483@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1127779977.10315.6.camel@localhost>
In-Reply-To: <1127779977.10315.6.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Tue Sep 27 2005, 06:00:32PM EDT]
> >Okay. There was a bug in my Kconfig.  All defconfigs and my own memory model
> >configs build correctly and produce the correct config options.  Below is
> >a replacement for patch 1/4 which I've included for your config testing.  I'll
> >post V5 patchset when we agree on where we want to proceed with config(s).  
> 
> Yup, all my configs now build too (includes some of the distributed ones
> with CONFIG_SMP turned off).  I booted three sample kernels (zx1,
> generic and generic with s/discontig/sparse/) on rx2620 with nothing
> odd happening.
> 
> >I'm thinking all we need is sparsemem_defconfig which is defconfig but with
> >the SPARSEMEM memory model.
> 
> That would do as a starting point ... it gives me an easy hook
> into my automatic build script to make sure that SPARSEMEM is being
> test compiled.
Okay I'll provide this.
> 
> Do you have, or can you generate, the full list of all the combinations
> of memory model related options that Kconfig will accept?
Yes. I can send three of my test configurations: 1) FLATMEM, 
2) DISCONTIGMEM and 3) SPARSEMEM (which will be in sparsemem_defconfig).  This 
should be representative of what you'd like.

I'll post to you privately unless someone on this thread requests them.
> 
> -Tony
bob
