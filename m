From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jul 2005 21:34:23 +0000
Subject: RE: [patch 2.6.13-rc1] assign_irq_vector() should not panic
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03DC34F5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C51286.5020507@jp.fujitsu.com>
In-Reply-To: <42C51286.5020507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>The following patch changes assign_irq_vector() for ia64 to return
>negative value on error instead of panic.

The i386 and x86_64 versions of this return -ENOSPC rather than -1.  Perhaps
we should do the same?

There are a couple of ia64 specific uses of assign_irq_vector in hp/sim/simeth.c
and hp/sim/simserial.c that don't check the return value ... if you make this
change, then they need to check for failure too.

-Tony
