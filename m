From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 31 Jan 2006 15:26:05 +0000
Subject: Re: [patch 1/6] align kenrel rbs on 128 byte
Message-Id: <200601311526.k0VFQ5FB907159@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
In-Reply-To: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenneth Chen wrote:
> Keith Owens wrote on Tuesday, January 31, 2006 12:57 AM
> > 
> > The cache lines are not guaranteed to be 128 byte aligned, they
> > were 64 on bigsur.  Change 127 to (L1_CACHE_BYTES - 1).
> 
> That did cross my mind and L1_CACHE_BYTES is such a misleading
> name.  In my head, L1 means the cache level closest to the CPU
> core, but here it appears to represent last level cache line.
> Do we have the numbering scheme reversed?  I have no idea what's
> going on here. 

I agree that L1_CACHE_BYTES is misleading.  Looking at
the usage, most (if not all) references expect the 
last (external/FSB) cache line size, not caches closer
to the core.  As Jes points out SMP_CACHE_BYTES is
more what they mean.

Why not just call it CACHE_BYTES, meaning the last cache
level.  Handling of caches closer to the core most likely
should be through PAL, or, it really needed, use the 
engineering cache level prefix.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
