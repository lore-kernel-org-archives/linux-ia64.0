From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 15 Mar 2005 12:40:21 +0000
Subject: flush_icache_range
Message-Id: <4236D7B5.8050408@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Apparently, the function flush_icache_range() flushes the
caches 32 by 32 bytes.
According to some measures on a Tiger box, an "fc" instruction
costs 200 nanosec. if no other CPU has the line its cache,
there is no traffic on the bus, everything is ideal.
If all the others CPUs have the line in their caches, they post
bus transactions, then the cost of an "fc" instruction is 5
microsec.
To flush a full page of 64 Kbytes, it can take 400 microsec. to
10 millisec.

Cannot we test at the boot time the characteristics of the
CPUs and select the optimal flush_icache_range() ? E.g.:
- if the CPU has 64 bytes / L1 lines =>
	flush by use of 64 byte steps
- if the CPU implements the "fc.i" instruction =>
	flush the I-caches only

Thanks,

Zoltan Menyhart
