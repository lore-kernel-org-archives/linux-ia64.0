From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Feb 2006 20:17:17 +0000
Subject: RE: Export cpu cache info by sysfs
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05C7C924@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This patch exports cpu cache info which is similar to
> /proc/pal/cpuX/cache_info.

But is it similar to what i386/x86_64/anyone-else has already
done?

> One important new item is shared_cpu_map.
> shared_cpu_map showes the cpu map sharing the cache.

Looks like this could be useful for applications that want to
pin tasks to specific cpus (or set of cpus).

Some of the attributes print in a somewhat unsysfs way ... e.g.
do we really need " cycle(s)" after the load_latency and store_latency
value (could it ever be anything else?).  Similarly "load_hints" and
"store_hints" look unnecessarily complex for a program to parse.
Printing sizes as 16K, 256K etc. is also good for human readability
but worse for programs to parse.

Finally, I count 65 new nodes in /sys per cpu on my 4-way Madison
box (the "cache" directory, "index0" .. "index3", and then 15 attributes
per cache level).  So when SGI start making use of the CONFIG_NR_CPUS24
that we recently added, they can look forward to 66560[1] more nodes
in /sys ... is this the best way to export this information?  Do we
really need to add all of these to the user-kernel API (see long
discussion thread on LKML about how you can't change this once you
add it).

I know that sysfs is supposed to be the wave of the future, but it looks
like /proc/pal/cpuX/cache_info may be a better way to handle this.

-Tony

[1] Actually it will be worse than this as Montecito has split I&D
cache at the mid-level instead of combined, so there will be five
"index" directories and a total of 81 nodes/cpu => 82944 total.
