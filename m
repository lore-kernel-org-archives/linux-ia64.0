From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Feb 2005 00:18:16 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2BD9D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Likely yes.
>That's one of two errors I see on parisc-linux when a register
>is corrupted (segfaults are the symptom). And unfortunately
>the context switching has a corner case the tickles that bug
>on a regular basis. :^(

I wrote a test program that loads up random values into registers
(just r1-r31, a bunch of stacked registers, and f2-f127 for now)
and then checks that all the registers haven't changed value a
few thousand times, before reloading with a new set of random
values.

I'm running that along with an MCA every 15 seconds.

It just went bang, saying that "f6" was corrupted ... but I'm
not doing the right things to tickle the corner case on a regular
basis ... so I only have the one data point so far.

-Tony
