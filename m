From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 18:00:07 +0000
Subject: [PATCH 0/5] IA64: Fine-tuning for some function implementations
Message-Id: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Paolo Bonzini <pbonzini@redhat.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 19:54:32 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  IRQ: Use kmalloc_array() in sn_irq_lh_init()
  IRQ: Delete unnecessary braces
  TLB: Fix indentation in ia64_global_tlb_purge()
  TLB: Use kmalloc_array() in ia64_itr_entry()
  TLB: Delete unnecessary braces

 arch/ia64/mm/tlb.c        | 19 ++++++++-----------
 arch/ia64/sn/kernel/irq.c | 29 +++++++++++------------------
 2 files changed, 19 insertions(+), 29 deletions(-)

-- 
2.9.3

