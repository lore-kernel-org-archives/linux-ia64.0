From: "de Dinechin, Christophe (Integrity VM)"
Date: Fri, 14 Dec 2007 17:17:10 +0000
Subject: RE: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating
Message-Id: <7575980D7C4188408E8BDB171DA164B73A875EC00C@G3W1111.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
 <1FE6DD409037234FAB833C420AA843EC1A3F5B@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC1A3F5B@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Picco, Robert W." <robert.picco@hp.com>

Hi Tony,


Thanks for testing this. I just tried the following on a 4-way virtual machine with 2G of memory running on a 4-way rx5670 host with 14G:

        # One window: Fill the buffer cache with some stuff
        while true; do find / -type f | xargs cat > /dev/null; done

        # Another window: do some memory allocations
        cd /usr/src/linux-2.6.23.9
        while true; do gmake clean; gmake -j50; done

I also added some instrumentation that shows old and new PTC.E in /proc/meminfo. Here is what a grep of PTC.E in /proc/meminfo gives me every second under that load, after waiting until the buffer cache fills up:

        Fri Dec 14 23:27:16 CET 2007: PTC.E: 1161198 (old) 0 (new)
        Fri Dec 14 23:27:17 CET 2007: PTC.E: 1166233 (old) 0 (new)
        Fri Dec 14 23:27:19 CET 2007: PTC.E: 1174342 (old) 0 (new)
        Fri Dec 14 23:27:20 CET 2007: PTC.E: 1175436 (old) 0 (new)
        Fri Dec 14 23:27:21 CET 2007: PTC.E: 1176494 (old) 0 (new)
        Fri Dec 14 23:27:22 CET 2007: PTC.E: 1176756 (old) 0 (new)

As you can see, the global purge rates can be pretty respectable under this kind of load. I chose -j50 to generate enough processes to stress my own system, you may need more with 4G. Check with xosview or similar that the buffer cache fills up memory but is kept relatively small by user-space memory pressure (at around 5-10% for my own testing).

If for some reason the same effect does not show up on your system, then that would be very interesting... Please let me know.


Regards
Christophe

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Luck, Tony
Sent: Thursday, December 13, 2007 10:07 PM
To: de Dinechin, Christophe (Integrity VM); linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org; Picco, Robert W.
Subject: RE: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating memory

> Test case: Run 'find /usr -type f | xargs cat > /dev/null'
> in the background to fill the buffer cache, then run something that
> uses memory, e.g. 'gmake -j50 install'.
> Instrumentation showed that the number of global TLB purges went from
> a few millions down to about 170 over a 12 hours run of the above.

What was your system configuration for this test.  I'm running on a 4 socket Montecito (with HT enabled, so 16 logical cpus) with 4G of memory.  In the first hour of my test I've only seen 125 calls where the old code would have called flush_tlb_all().
The new code managed to avoid all of these ... so it is batting 100%. This is out of just over a million calls to ia64_global_tlb_purge().

So clearly I'm not manage to stress the system as heavily as you did.

-Tony
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
