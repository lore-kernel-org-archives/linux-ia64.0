From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 30 Jul 2012 17:18:57 +0000
Subject: [GIT PULL] Miscellaneous ia64 build fixes
Message-Id: <5016c2013018736bd3@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 28a33cbc24e4256c143dce96c7d93bf423229f92:

  Linux 3.5 (2012-07-21 13:58:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-ia64-fixes

for you to fetch changes up to a119365586b0130dfea06457f584953e0ff6481d:

  [IA64] Redefine ATOMIC_INIT and ATOMIC64_INIT to drop the casts (2012-07-26 10:55:26 -0700)

----------------------------------------------------------------
Miscellaneous ia64 build fixes

----------------------------------------------------------------
Fengguang Wu (2):
      [IA64] Mark PARAVIRT and KVM as broken
      [IA64] Rename platform_name to ia64_platform_name

Tony Luck (1):
      [IA64] Redefine ATOMIC_INIT and ATOMIC64_INIT to drop the casts

 arch/ia64/Kconfig                             | 3 +--
 arch/ia64/include/asm/atomic.h                | 4 ++--
 arch/ia64/include/asm/machvec.h               | 2 +-
 arch/ia64/include/asm/machvec_dig.h           | 2 +-
 arch/ia64/include/asm/machvec_dig_vtd.h       | 2 +-
 arch/ia64/include/asm/machvec_hpsim.h         | 2 +-
 arch/ia64/include/asm/machvec_hpzx1.h         | 2 +-
 arch/ia64/include/asm/machvec_hpzx1_swiotlb.h | 2 +-
 arch/ia64/include/asm/machvec_sn2.h           | 2 +-
 arch/ia64/include/asm/machvec_uv.h            | 2 +-
 arch/ia64/include/asm/machvec_xen.h           | 2 +-
 arch/ia64/include/asm/processor.h             | 2 +-
 arch/ia64/kvm/Kconfig                         | 1 +
 arch/ia64/pci/fixup.c                         | 4 ++--
 drivers/char/mspec.c                          | 2 +-
 15 files changed, 17 insertions(+), 17 deletions(-)
