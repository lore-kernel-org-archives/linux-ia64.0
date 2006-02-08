From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Feb 2006 18:18:18 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05A6DE63@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hadn't seen this effect since the SN2 use the global clock source which
> is in sync for all CPUs. Would it make sense to use the HPET on systems
> that got it?

It might be useful for a system with non-synchronized ar.itc to stop them
falling back to jiffie resolution.  But I think sn2 is the only one of those
right now, and you've already got this covered.

The odd 0.000000 values during boot can easily be worked around by anyone
looking to use this to analyse and improve boot time.  I was just amused
that there were three different reasons why a 0.000000 value would be
printed.

-Tony
