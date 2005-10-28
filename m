From: "Peter Keilty" <Peter.Keilty@hp.com>
Date: Fri, 28 Oct 2005 18:49:25 +0000
Subject: RE: ia64 get_mmu_context patch
Message-Id: <200510281850.j9SIo5o0001313539@kitche.zk3.dec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
In-Reply-To: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 
Ken,

It well be worth doing find_next_zero_bit from get_mmu_context 
Per your patch instead of the global tbl flush.

> -----Original Message-----
> From: Chen, Kenneth W [mailto:kenneth.w.chen@intel.com] 
> Sent: Friday, October 28, 2005 2:41 PM
> To: 'Peter Keilty'; linux-ia64@vger.kernel.org
> Cc: 'Eric Whitney'
> Subject: RE: ia64 get_mmu_context patch
> 
> I did a crude fork bomb test, then printed out ia64_ctx.next 
> ia64_ctx.limit and the diff in wrap_mmu_context().  Here is 
> the result:
> 
> First call resulted expected 2M hole.  Look what happens 
> after first wrap.  My worst fear of global tlb flush after 
> just one ctx_id allocation is actually happening!  Average ~ 
> 90,000 ctx_id allocation between flush.  Much smaller than 
> advertised 2^21.  This find_next_hole() is horribly broken in 
> terms of performance.
> 
> - Ken
> 
> 
> wrap_mmu_context: next = 32767, limit = 2097152 n = 2064385
> wrap_mmu_context: next = 300, limit = 1782 n = 1482
> wrap_mmu_context: next = 1783, limit = 1872 n = 89
> wrap_mmu_context: next = 1873, limit = 1883 n = 10
> wrap_mmu_context: next = 1884, limit = 1921 n = 37
> wrap_mmu_context: next = 1922, limit = 1973 n = 51
> wrap_mmu_context: next = 1974, limit = 1998 n = 24
> wrap_mmu_context: next = 1999, limit = 2055 n = 56
> wrap_mmu_context: next = 2056, limit = 2109 n = 53
> wrap_mmu_context: next = 2110, limit = 2111 n = 1
> wrap_mmu_context: next = 2118, limit = 2124 n = 6
> wrap_mmu_context: next = 2125, limit = 2128 n = 3
> wrap_mmu_context: next = 2129, limit = 140411 n = 138282
> wrap_mmu_context: next = 140412, limit = 518442 n = 378030
> wrap_mmu_context: next = 518443, limit = 520789 n = 2346
> wrap_mmu_context: next = 520790, limit = 980204 n = 459414
> wrap_mmu_context: next = 980205, limit = 1864365 n = 884160
> wrap_mmu_context: next = 1864366, limit = 1864528 n = 162
> wrap_mmu_context: next = 1864529, limit = 2066917 n = 202388
> wrap_mmu_context: next = 2066918, limit = 2097152 n = 30234
> wrap_mmu_context: next = 300, limit = 1782 n = 1482
> wrap_mmu_context: next = 1783, limit = 1872 n = 89
> wrap_mmu_context: next = 1873, limit = 1883 n = 10
> wrap_mmu_context: next = 1884, limit = 1921 n = 37
> wrap_mmu_context: next = 1922, limit = 1973 n = 51
> wrap_mmu_context: next = 1974, limit = 1998 n = 24
> wrap_mmu_context: next = 1999, limit = 2055 n = 56
> wrap_mmu_context: next = 2056, limit = 2109 n = 53
> wrap_mmu_context: next = 2110, limit = 2111 n = 1
> wrap_mmu_context: next = 2118, limit = 2124 n = 6
> wrap_mmu_context: next = 2125, limit = 2128 n = 3
> wrap_mmu_context: next = 2129, limit = 140411 n = 138282
> wrap_mmu_context: next = 140412, limit = 184686 n = 44274
> wrap_mmu_context: next = 184687, limit = 188664 n = 3977
> wrap_mmu_context: next = 188665, limit = 398496 n = 209831
> wrap_mmu_context: next = 398497, limit = 492604 n = 94107
> wrap_mmu_context: next = 492605, limit = 510747 n = 18142
> wrap_mmu_context: next = 510748, limit = 510923 n = 175
> wrap_mmu_context: next = 510924, limit = 518442 n = 7518
> wrap_mmu_context: next = 518443, limit = 520789 n = 2346
> wrap_mmu_context: next = 520790, limit = 980204 n = 459414
> wrap_mmu_context: next = 980205, limit = 1864365 n = 884160
> wrap_mmu_context: next = 1864366, limit = 1864528 n = 162
> wrap_mmu_context: next = 1864529, limit = 2097152 n = 232623
> wrap_mmu_context: next = 300, limit = 1782 n = 1482
> wrap_mmu_context: next = 1783, limit = 1872 n = 89
> wrap_mmu_context: next = 1873, limit = 1883 n = 10
> wrap_mmu_context: next = 1884, limit = 1921 n = 37
> wrap_mmu_context: next = 1922, limit = 1973 n = 51
> wrap_mmu_context: next = 1974, limit = 1998 n = 24
> wrap_mmu_context: next = 1999, limit = 2055 n = 56
> wrap_mmu_context: next = 2056, limit = 2109 n = 53
> wrap_mmu_context: next = 2110, limit = 2111 n = 1
> wrap_mmu_context: next = 2118, limit = 2124 n = 6
> wrap_mmu_context: next = 2125, limit = 2128 n = 3
> wrap_mmu_context: next = 2129, limit = 140411 n = 138282
> wrap_mmu_context: next = 140412, limit = 184686 n = 44274
> wrap_mmu_context: next = 184687, limit = 188664 n = 3977
> wrap_mmu_context: next = 188665, limit = 398496 n = 209831
> wrap_mmu_context: next = 398497, limit = 492604 n = 94107
> wrap_mmu_context: next = 492605, limit = 510747 n = 18142
> wrap_mmu_context: next = 510748, limit = 510923 n = 175
> wrap_mmu_context: next = 510924, limit = 518442 n = 7518
> wrap_mmu_context: next = 518443, limit = 520789 n = 2346
> wrap_mmu_context: next = 520790, limit = 980204 n = 459414
> wrap_mmu_context: next = 980205, limit = 1864365 n = 884160
> wrap_mmu_context: next = 1864366, limit = 1864528 n = 162
> wrap_mmu_context: next = 1864529, limit = 2097152 n = 232623
> 
> 


