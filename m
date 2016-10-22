From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 19:50:45 +0000
Subject: [PATCH 0/6] IA64: Fine-tuning for five function implementations
Message-Id: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Borislav Petkov <bp@suse.de>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>, Ingo Molnar <mingo@kernel.org>, =?UTF-8?B?SsO2cmcgUsO2ZGVs?= <jroedel@suse.de>, Krzysztof Kozlowski <krzk@kernel.org>, Robert Richter <rrichter@cavium.com>, Robin Murphy <robin.murphy@arm.com>, Tony Luck <tony.luck@intel.com>, Toshi Kani <toshi.kani@hpe.com>, Vineet Gupta <vgupta@synopsys.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 21:27:32 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (6):
  sba_iommu: Use seq_puts() in ioc_show()
  sba_iommu: Combine four seq_printf() calls into two calls in ioc_show()
  simserial: Use seq_puts() in rs_proc_show()
  setup: Use seq_putc() in show_cpuinfo()
  sn_hwperf: Use seq_puts() in sn_topology_show()
  sn2_smp: Combine two seq_printf() calls into one call in sn2_ptc_seq_show()

 arch/ia64/hp/common/sba_iommu.c     | 16 +++++++++++-----
 arch/ia64/hp/sim/simserial.c        |  2 +-
 arch/ia64/kernel/setup.c            |  3 +--
 arch/ia64/sn/kernel/sn2/sn2_smp.c   |  9 ++++-----
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |  6 +++---
 5 files changed, 20 insertions(+), 16 deletions(-)

-- 
2.10.1

