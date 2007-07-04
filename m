From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 04 Jul 2007 14:24:38 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <468BADA6.9050609@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426001615.GA8908@ldl.fc.hp.com>
In-Reply-To: <20070426001615.GA8908@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Could you please confirm that I understand correctly what is in the:

Dual-Core Update to the Intel Itanium 2 Processor Reference Manual...

"2.3.3.2 L2 Caches
...
Any coherence request to identify whether a cache line is in the processor
will invalidate that line from the L2I cache."

This makes sure that the DMAs invalidate the L2L cache.

"2.7.4 Instruction Cache Coherence Optimization
Coherence requests of the L1I and L2I caches will invalidate the line if
it is in the cache. Montecito allows instruction requests on the system
interface to be filtered such that they will not initiate coherence
requests of the L1I and L2I caches. This will allow instructions to be
cached at the L1I and L2I levels across multiple processors in a coherent
domain. This optimization is enabled by default, but may be disabled by
PAL_SET_PROC_FEATURES bit 5 of the Montecito feature_set (18)."

Machines star up whit bit 5 = 0, reading instruction pages via
NFS has to flush them from L2I.


I was wondering if instead of modifying do_no_page() and Co., should
not we make nfs_readpage() be DMA-like?
(No possible regression for most of the page I/O-s.)
I.e. it should be the responsibility of a file system to make sure it
supports instruction pages correctly. The base kernel should provide
such file systems with an architecture dependent macro...

Thanks,

Zoltan Menyhart
