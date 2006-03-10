From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Mar 2006 16:47:57 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05EC7A9A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>	itc.d	r25
>	;;
>	srlz.d
>	ld8	r18 = [r17]

But it does not matter to the "ld8 r18 = [r17]" whether the "itc.d"
is visible or not.  r17 cannot be in the virtual address range that
will be affected by the itc.d, so the serialization here would just
slow things down, and have no effect at all.

-Tony
