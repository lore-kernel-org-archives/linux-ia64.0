From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Dec 2007 21:07:24 +0000
Subject: RE: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating memory
Message-Id: <1FE6DD409037234FAB833C420AA843EC1A3F5B@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
In-Reply-To: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "de Dinechin, Christophe (Integrity VM)" <christophe.de-dinechin@hp.com>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, "Picco, Robert W." <robert.picco@hp.com>

> Test case: Run 'find /usr -type f | xargs cat > /dev/null'
> in the background to fill the buffer cache, then run
> something that uses memory, e.g. 'gmake -j50 install'.
> Instrumentation showed that the number of global TLB
> purges went from a few millions down to about 170 over
> a 12 hours run of the above.

What was your system configuration for this test.  I'm running
on a 4 socket Montecito (with HT enabled, so 16 logical cpus)
with 4G of memory.  In the first hour of my test I've only
seen 125 calls where the old code would have called flush_tlb_all().
The new code managed to avoid all of these ... so it is batting
100%. This is out of just over a million calls to
ia64_global_tlb_purge().

So clearly I'm not manage to stress the system as heavily
as you did.

-Tony
