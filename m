From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Jul 2003 15:22:37 +0000
Subject: RE: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105836903607087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> Altix/SN2 presently has the PAL located in a granule that has mixed
> cachability --- for this reason we need to map the PAL using the
> smallest mapping possible.

I tried some similar code for Tiger a while ago, but ran into a problem
as there is other code in the same granule, that isn't covered by the
address range for PAL routines (I think that the other code was the
EFI loaded FPSWA code, but I didn't look too closely at the time this
happened).  As soon as the processor tried to execute this other code,
the Alt-ITLB handler tried to insert a mapping for the whole granule,
which overlaps with the ITR[1] that was set to map the PAL, and boom,
the system died with a machine check.

If SN2 guarantees that the PAL code is the only executable code in the
whole of your mixed cacheability granule, then this code is safe.

-Tony
