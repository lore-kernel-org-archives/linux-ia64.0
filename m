From: Alex Chiang <achiang@hp.com>
Date: Wed, 17 Sep 2008 00:08:17 +0000
Subject: Re: Kernel now broken on Ski simulator
Message-Id: <20080917000817.GC10224@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87hc8yddun.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87hc8yddun.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Peter Chubb <peterc@gelato.unsw.edu.au>:
> >>>>> "Alex" = Alex Chiang <achiang@hp.com> writes:
> 
> Alex> * Luck, Tony <tony.luck@intel.com>:
> >> > Until Ski is fixed to implement IPIs, you need to boot with the >
> >> force_pal_cache_flush argument to the kernel.
> >> 
> >> We could #ifndef CONFIG_IA64_HP_SIM around the test (since the
> >> simulator presumably doesn't have the SAL cache flush bug :-)
> 
> Alex> Hm, I started playing with this and turns out I started peeling
> Alex> an onion I didn't really want to touch...
> 
> Bad config file I think.  Start with make sim_defconfig and go on from
> there.

Oh hrm, you're right.

I'm only slightly embarassed... :-/

Thanks.

/ac

