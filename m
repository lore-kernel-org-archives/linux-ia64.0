From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Jan 2006 17:45:20 +0000
Subject: RE: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060105213948.11412.45463.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060105213948.11412.45463.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Arjan van de Ven <arjan@infradead.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

>Why can't we keep the default below 64?  Surely the 0.1% of the market
>which needs more than 64 cpus can recompile their kernel ...

I suppose that depends on your expectations from defconfig.  In my
mind its the one that builds into a kernel that will boot and run
on just about any box.  People who want to get a bit of extra performance
will do the re-compilation to strip out the bits that they don't want
and tune down limits that are set higher than they need.  I only
ever boot a defconfig kernel to check that it still works, my systems
all run tiger_defconfig/zx1_defconfig based most of the time.  But
perhaps I'm the weird one?

There are quite a few >16 socket boxes out there, which will give
you >64 cpus with Montecito ... so I don't think that the >64 cpu
system is going to remain in the noise for long.

-Tony
