From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Apr 2014 18:20:54 +0000
Subject: [GIT PULL] Fix Itanium erratum #237
Message-Id: <534eca0627065dda44@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit b098d6726bbfb94c06d6e1097466187afddae61f:

  Linux 3.14-rc8 (2014-03-24 19:31:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-ia64-erratum

for you to fetch changes up to c0b5a64d937f8fff79b10410a8a70ecaa9a1c580:

  [IA64] Change default PSR.ac from '1' to '0' (Fix erratum #237) (2014-04-16 10:20:34 -0700)

----------------------------------------------------------------
Small workaround for a rare, but annoying, erratum

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Change default PSR.ac from '1' to '0' (Fix erratum #237)

 arch/ia64/kernel/head.S | 2 +-
 arch/ia64/kernel/ivt.S  | 2 +-
 arch/ia64/kvm/vmm_ivt.S | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)
