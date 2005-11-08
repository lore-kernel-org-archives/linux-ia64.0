From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 08 Nov 2005 20:27:17 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <200511082027.jA8KRHg18986@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Tuesday, November 08, 2005 11:37 AM
> Can I get you to reproduce this?  I have tried many times and
> your test is giving me numbers that are very close between 3
> and 4 level page tables.  For 25 runs, I got:
> 
> With 3-level page table kernel: Average of 25 is 24612659771.96
> With 4-level page table kernel: Average of 25 is 24686556792.96
> 
> Which is showing that a vhtp_miss test is adding a 0.30% overhead
> which can also be expressed as an average 1.44 clock cycles per
> miss.  As of this writing, the loops have run over 250 times and
> the min reading to this point is 23946196482.  This is nowhere
> close to your min reported.

The other option is to instrument vhpt_miss handler and measure
average clock ticks spend in that handler.  I had that instrumented
and measured with 3-level/4-level page table configurations.  I
measured 221 clocks with 3-level page table, versus 298 clocks with
4-level page table [*].  This measurement is certainly depends on
system chipset/platform.  But the point is that penalty with 4-level
page table is certainly visible.  Not only the low level hander has
to Walk the extra level, it also incurs additional cache misses while
walking the table, and it has damaging side effect of evicting other
Working set data resides in the cache.

- Ken

[*] measured on: 1.6 GHz Itainum2 processor, 9M L3, Intel server platform
    SR870BN4.  32GB PC2100 DDR memory.

