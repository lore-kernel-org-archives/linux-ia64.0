From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 17 Sep 2008 00:01:40 +0000
Subject: Re: Kernel now broken on Ski simulator
Message-Id: <87ljxrtzbv.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <87hc8yddun.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87hc8yddun.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Alex" = Alex Chiang <achiang@hp.com> writes:

Alex> * Luck, Tony <tony.luck@intel.com>:
>> > Until Ski is fixed to implement IPIs, you need to boot with the >
>> force_pal_cache_flush argument to the kernel.
>> 
>> We could #ifndef CONFIG_IA64_HP_SIM around the test (since the
>> simulator presumably doesn't have the SAL cache flush bug :-)

Alex> Hm, I started playing with this and turns out I started peeling
Alex> an onion I didn't really want to touch...

Bad config file I think.  Start with make sim_defconfig and go on from
there.

Peter C
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
