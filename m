From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jul 2003 23:54:43 +0000
Subject: RE: 2.5.75 out
Message-Id: <marc-linux-ia64-105788133314878@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105788013113852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105788013113852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Jul 2003 16:45:52 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> There is good and bad news: the bad news is that 2.5.75 doesn't work
  >> out-of-the-box on ia64.  The good news it _does_ compile.  The thing
  >> that keeps it from working are a few (late) per-CPU related changes.
  >> Hopefully, we can iron those out before pre-2.6 comes out so that it
  >> will build _and_ work.  Probably wishful thinking though.  There
  >> always seems to be that last-minute patch that breaks things...

  Tony> Compiles, but doesn't link for me ... Linus's tree is missing
  Tony> this patch:

Ah, I have the AGP stuff configured as modules so I didn't notice
(didn't build the modules).

  Tony> diff ~/BK/david2.5/drivers/char/agp/i460-agp.c drivers/char/agp/i460-agp.c
  Tony> 611c611
  >> .remove         = agp_intel_i460_remove,
  Tony> ---
  Tony> <       .remove         = __exit_p(agp_intel_i460_remove),
  Tony> -
  Tony> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in

Can you submit this directly to Dave Jones?  Have you actually tried i460
AGP recently?  Does it still work?

	--david
