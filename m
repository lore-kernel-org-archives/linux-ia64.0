From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 10 Sep 2008 21:17:37 +0000
Subject: [git pull] ia64 changes
Message-Id: <200809102117.m8ALHbrC031210@agluck-lia64.sc.intel.com>
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

 arch/ia64/include/asm/elf.h       |   15 +++++++++++++++
 arch/ia64/include/asm/sections.h  |   13 ++++++++++++-
 arch/ia64/include/asm/sn/bte.h    |    9 +++++----
 arch/ia64/kernel/module.c         |   21 ---------------------
 arch/ia64/kernel/smpboot.c        |    4 +---
 arch/ia64/sn/pci/tioca_provider.c |    4 +++-
 6 files changed, 36 insertions(+), 30 deletions(-)

James Bottomley (1):
      [IA64] fix compile failure with non modular builds

Julia Lawall (1):
      [IA64] arch/ia64/sn/pci/tioca_provider.c: introduce missing kfree

Paul E. McKenney (1):
      [IA64] prevent ia64 from invoking irq handlers on offline CPUs

Robin Holt (1):
      [IA64] fix up bte.h

