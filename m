From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Jul 2004 23:14:39 +0000
Subject: RE: free bootmem feedback patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01A5D0FC@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>NUMA machines with a lot of memory/nodes appear to hang when 
>freeing boot memory, as it can take on the order of 4 minutes. 

Isn't this a feature of the amount of memory being freed, rather
than the fact that there are many nodes?  I.e. if someone has a
single node box with a few TB of memory, they'll still have the
multi-minute delay, but your patch won't give them any progress
dots.

-Tony
