From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Mon, 09 Aug 2004 06:17:13 +0000
Subject: RE: pgd/pmd page error of kernel 2.6.8-rc3 when CONFIG_PREEMPT=y
Message-Id: <C0ECD887E2CBE349ACF9C483510BF8381C22E4@pdsmsx401.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E8419909D@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E8419909D@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We think they are different problems.
Thanks to Peter chubb's Patch.
2.6.8-rc1-mm1 kernel really enabled preempt on IA64. 

Start 12 instances of this script on a 4-CPU IPF machine.
#!/bin/sh
while true;do f=`mktemp`;touch $f;rm $f;done;
System will crash within 2 minutes.

After applying our patch, system will live after a 12 hours test.

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of William Lee Irwin
III
Sent: Monday, August 09, 2004 1:43 PM
To: Zhang, Yanmin
Cc: linux-ia64@vger.kernel.org; Luck, Tony
Subject: Re: pgd/pmd page error of kernel 2.6.8-rc3 when
CONFIG_PREEMPT=y

On Mon, Aug 09, 2004 at 12:35:43PM +0800, Zhang, Yanmin wrote:
> There is a bug in kernel 2.6.8-rc3 when CONFIG_PREEMPT=y. See the
below
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
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
