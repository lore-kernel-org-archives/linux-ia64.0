From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 05 Jun 2006 20:37:42 +0000
Subject: RE: Montecito processor family
Message-Id: <617E1C2C70743745A92448908E030B2A0AF2B5@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > model name : Intel(r) Itanium(r) 2 Processor 1.6GHz with 24M L3 Cache for 533MHz Platforms
>
> Presumably this would be the same string that's used in the processor
> manuals?  If so, that would be really helpful to have.

The same person at Intel provides the string to the PAL team for the
PAL_BRAND_INFO call as gets used in the manuals.  So the goal is that
they should be the same.  But the reaction time of print-media and
PAL releases is different, so when branding changes happen, the strings
may get out of sync.  That's apparently the case here: print manuals
will include the 9xxx processor model number, but current PAL doesn't
have that.

-Tony
