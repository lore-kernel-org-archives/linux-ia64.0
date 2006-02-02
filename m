From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Feb 2006 21:46:05 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F059C0653@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Jack, I think this is the thread you are looking for:
>    http://marc.theaimsgroup.com/?l=linux-ia64&m2422250517703&w=2

The current state of the tree is that Andrew added the patch
to make the definition of printk_clock() in kernel/printk.c
"__attribute__((weak))" so that architectures could override
with their own version.  Default version uses sched_clock().

So far we haven't made use of this ... but we need to do it (partly
because it crashes early on Altix, but also because it returns
meaningless values on any system where the clocks are not synched
on different cpus (perhaps just Altix).

-Tony
