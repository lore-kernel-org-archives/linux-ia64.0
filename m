From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Fri, 24 Feb 2006 02:19:44 +0000
Subject: RE: Export cpu cache info by sysfs
Message-Id: <1140747584.15042.35.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-02-24 at 04:17, Luck, Tony wrote:
> > This patch exports cpu cache info which is similar to
> > /proc/pal/cpuX/cache_info.
> 
> But is it similar to what i386/x86_64/anyone-else has already
> done?
Yes. The one on i386/x86_64 has attributes:
1) level
2) type
3) coherency_line_size
4) ways_of_associativity
5) size
6) shared_cpu_map
7) physical_line_partition
8) number_of_sets

My patch doesn't have the last 2 attributes, but it has other 9
attributes.

> 
> > One important new item is shared_cpu_map.
> > shared_cpu_map showes the cpu map sharing the cache.
> 
> Looks like this could be useful for applications that want to
> pin tasks to specific cpus (or set of cpus).
> 
> Some of the attributes print in a somewhat unsysfs way ... e.g.
> do we really need " cycle(s)" after the load_latency and store_latency
> value (could it ever be anything else?).  Similarly "load_hints" and
> "store_hints" look unnecessarily complex for a program to parse.
> Printing sizes as 16K, 256K etc. is also good for human readability
> but worse for programs to parse.
On i386/x86_64, size also has 'K' and type is also a string. Perhaps
I could delete some attibutes, such like 
load_hints/store_hints/tag_lsb/tag_msb/alias_boundary/stride,
and delete 'cycle(s)' from the output of store_latency/load_latency?



> 
> Finally, I count 65 new nodes in /sys per cpu on my 4-way Madison
> box (the "cache" directory, "index0" .. "index3", and then 15 attributes
> per cache level).  So when SGI start making use of the CONFIG_NR_CPUS24
> that we recently added, they can look forward to 66560[1] more nodes
> in /sys ... is this the best way to export this information?  Do we
> really need to add all of these to the user-kernel API (see long
> discussion thread on LKML about how you can't change this once you
> add it).
It's a problem. It could be mitigated by deleting some attributes,
but couldn't be resolved thoroughly.



> 
> I know that sysfs is supposed to be the wave of the future, but it looks
> like /proc/pal/cpuX/cache_info may be a better way to handle this.
> 
> -Tony
> 
> [1] Actually it will be worse than this as Montecito has split I&D
> cache at the mid-level instead of combined, so there will be five
> "index" directories and a total of 81 nodes/cpu => 82944 total.

