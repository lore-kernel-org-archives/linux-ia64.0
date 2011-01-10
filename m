From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 Jan 2011 18:01:34 +0000
Subject: [git pull] ia64 changes
Message-Id: <4d2b497e20144bc6c6@agluck-desktop.sc.intel.com>
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

 arch/ia64/kernel/acpi.c     |    6 ++++++
 arch/ia64/kernel/irq_ia64.c |    2 +-
 arch/ia64/kernel/perfmon.c  |    3 +--
 arch/ia64/kernel/smp.c      |   13 ++++++++++---
 arch/ia64/kernel/time.c     |    2 +-
 5 files changed, 19 insertions(+), 7 deletions(-)

Dimitri Sivanich (1):
      [IA64] eliminate race condition in smp_flush_tlb_mm

Jesper Juhl (1):
      [IA64] perfmon: Change vmalloc to vzalloc and drop memset.

Jiri Slaby (1):
      [IA64] irq_ia64, use set_irq_chip

Joe Perches (1):
      [IA64] Remove unlikely from cpu_is_offline

Tony Luck (1):
      [IA64] Avoid array overflow if there are too many cpus in SRAT table

