From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Sun, 08 Jan 2012 13:32:20 +0000
Subject: [RFC PATCH v2 0/9] Remove useless on_each_cpu return value
Message-Id: <1326029549-2794-1-git-send-email-gilad@benyossef.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Michal Nazarewicz <mina86@mina86.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Grant Likely <grant.likely@secretlab.ca>, Rob Herring <rob.herring@calxeda.com>, linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

on_each_cpu() returns as its own return value the return value of
smp_call_function(). smp_call_function() in turn returns a hard
coded value of zero.

Some callers to on_each_cpu() waste cycles and bloat code space
by checking the return value to on_each_cpu(), probably for
historical reasons.

This patch set refactors callers to not test on_each_cpu()
(fixed) return value and then refactors on_each_cpu to
return void to avoid confusing future users.

In other words, this patch aims to delete 18 source code lines
while not changing any functionality :-)

I tested as best as I could the x86 changes and compiled some
of the others, but I don't have access to all the needed hardware
for testing. Reviewers and testers welcome!

The only change from the first version is the addition of a 
proper Signed-off-by line.

This patch set is also available on branch on_each_cpu_ret_v2
at git://github.com/gby/linux.git

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Michal Nazarewicz <mina86@mina86.com>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: David Airlie <airlied@linux.ie>
CC: dri-devel@lists.freedesktop.org
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: linuxppc-dev@lists.ozlabs.org
CC: devicetree-discuss@lists.ozlabs.org
CC: Richard Henderson <rth@twiddle.net>
CC: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
CC: Matt Turner <mattst88@gmail.com>
CC: linux-alpha@vger.kernel.org
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@redhat.com>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: x86@kernel.org
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: Will Deacon <will.deacon@arm.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-arm-kernel@lists.infradead.org


Gilad Ben-Yossef (9):
  arm: avoid using on_each_cpu hard coded ret value
  ia64: avoid using on_each_cpu hard coded ret value
  x86: avoid using on_each_cpu hard coded ret value
  alpha: avoid using on_each_cpu hard coded ret value
  ppc: avoid using on_each_cpu hard coded ret value
  agp: avoid using on_each_cpu hard coded ret value
  drm: avoid using on_each_cpu hard coded ret value
  smp: refactor on_each_cpu to void returning func
  x86: refactor wbinvd_on_all_cpus to void function

 arch/alpha/kernel/smp.c      |    7 ++-----
 arch/arm/kernel/perf_event.c |    2 +-
 arch/ia64/kernel/perfmon.c   |   12 ++----------
 arch/powerpc/kernel/rtas.c   |    3 +--
 arch/x86/include/asm/smp.h   |    5 ++---
 arch/x86/lib/cache-smp.c     |    4 ++--
 drivers/char/agp/generic.c   |    3 +--
 drivers/gpu/drm/drm_cache.c  |    3 +--
 include/linux/smp.h          |    7 +++----
 kernel/smp.c                 |    6 ++----
 10 files changed, 17 insertions(+), 35 deletions(-)

