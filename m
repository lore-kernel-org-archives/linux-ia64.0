From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 May 2006 00:56:40 +0000
Subject: RE: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06940344@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> A twist on that theme is to merge the parts of ia32 emulation in the
> ia64 kernel with the x86_64 architecture.  Where that makes sense,
> anyway.  Large portions of the ia32 emulation are already common with
> other CONFIG_COMPAT architectures, so reducing the amount of code
> reduces the amount of potentially buggy code ;-)

That would be good ... currently there is 5674 lines below arch/ia64/ia32/
If the majority of that were shared with x86_64 (which has a much
bigger testing population than ia64), it would help enormously.

> I've been meaning to get round to this for a while, but somehow I never
> quite have time.

That's always a problem.

-Tony
