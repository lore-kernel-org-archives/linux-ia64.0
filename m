From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 20 Apr 2009 17:32:46 +0000
Subject: [git pull] ia64 changes
Message-Id: <49ecb1be18769a0a7f@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/include/asm/paravirt_privop.h |    2 --
 arch/ia64/kernel/smp.c                  |   14 ++++++--------
 2 files changed, 6 insertions(+), 10 deletions(-)

Dimitri Sivanich (1):
      [IA64] smp_flush_tlb_mm() should only send IPI's to cpus in cpu_vm_mask

Isaku Yamahata (1):
      [IA64] fix allmodconfig compilation breakage.

Marcelo Tosatti (1):
      [IA64] export smp_send_reschedule

