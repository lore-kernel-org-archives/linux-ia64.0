From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 19 Nov 2004 18:46:14 +0000
Subject: RE: pte bit spin lock
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F026C5BCB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <419D9911.1080306@yahoo.com.au>
In-Reply-To: <419D9911.1080306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I was wondering if it might be possible to change arch/ia64/kernel/ivt.S
>routines that modify pte access bits, to first take a "spin 
>lock bit" in the pte before any other modifications to it, and clear the 
>lock bit when done?

Possible?  Anything is possible.  Is it a good idea?  I don't know, you'd
need some benchmark data to show which applications win, and which lose.
Obviously this spin-lock-bit will make some operations that are now cheap
become much more expensive ... whether you have an overall win would
depend on a lot of factors.

>And second question, a pte's memory doesn't ever get updated 
>transparently by the hardware on ia64, does it?

No.  The h/w VHPT walker on ia64 only _reads_ page tables, all updates
(setting dirty bits) are done by s/w in ivt.S or elsewhere in Linux.

-Tony
