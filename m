From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Jan 2005 00:02:47 +0000
Subject: RE: fixing 2.6.10 UP builds
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02B82AAF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I've regenerated this patch, original developed by Jesse 
>Barnes, against 2.6.10, which fixes UP builds.  I've also removed the bogus 
>header removals from the cyclone driver.
>
>I won't pretend to be able to explain the details, hopefully 
>Jesse recalls :)

I think that I pulled together all the pieces, but I still see
a couple of problems when trying to build a generic-UP kernel:

  CC      drivers/char/mmtimer.o
drivers/char/mmtimer.c: In function `mmtimer_tasklet':
drivers/char/mmtimer.c:502: structure has no member named `write_lock'
make[1]: *** [drivers/char/mmtimer.o] Error 1
make: *** [drivers/char/mmtimer.o] Error 2

  CC      arch/ia64/sn/kernel/sn2/sn_hwperf.o
In file included from arch/ia64/sn/kernel/sn2/sn_hwperf.c:33:
include/linux/nodemask.h: In function `__first_unset_node':
include/linux/nodemask.h:244: warning: passing arg 1 of `__find_next_zero_bit' discards qualifiers from pointer target type
arch/ia64/sn/kernel/sn2/sn_hwperf.c: In function `sn_hwperf_op_cpu':
arch/ia64/sn/kernel/sn2/sn_hwperf.c:360: warning: implicit declaration of function `smp_call_function_single'

-Tony
