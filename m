From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 09 Aug 2004 05:42:46 +0000
Subject: Re: pgd/pmd page error of kernel 2.6.8-rc3 when CONFIG_PREEMPT=y
Message-Id: <20040809054246.GI11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E8419909D@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E8419909D@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 09, 2004 at 12:35:43PM +0800, Zhang, Yanmin wrote:
> There is a bug in kernel 2.6.8-rc3 when CONFIG_PREEMPT=y. See the below
> error log. 
> Aug  6 09:23:53 tpcc-el4a3 kernel: mm/memory.c:449: bad pgd
> e0000003f45f4000.
> Aug  6 09:23:53 tpcc-el4a3 kernel: mm/memory.c:128: bad pgd
> e000000108a00000.
> Aug  6 09:23:54 tpcc-el4a3 kernel: kernel BUG at mm/page_alloc.c:792!
> Aug  6 09:23:54 tpcc-el4a3 kernel: rm[16480]: bugcheck! 0 [1]
> Aug  6 09:23:54 tpcc-el4a3 kernel: Modules linked in:
> Aug  6 09:23:54 tpcc-el4a3 kernel:
> Aug  6 09:23:54 tpcc-el4a3 kernel: Pid: 16480, CPU 1, comm:

Similar errors have been reported on i386, so this is likely to be
architecture-neutral:

Subject: Bug in 2.6.8-rc3 at mm/page_alloc.c:792 and mm/rmap.c:407
From: Oskar Berggren <beo@sgs.o.se>
To: linux-kernel@vger.kernel.org
Message-Id: <1091977911.7221.13.camel@pitr.ekb.sgsnet.se>


-- wli
