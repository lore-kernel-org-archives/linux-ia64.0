From: Mike Rapoport <rppt@kernel.org>
Date: Tue, 18 Aug 2020 10:15:49 +0000
Subject: [GIT PULL] Fix regression in IA-64 caused by page table allocation refactoring
Message-Id: <20200818101549.GN752365@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Linus,

The following changes since commit 9123e3a74ec7b934a4a099e98af6a61c2f80bbf5:

  Linux 5.9-rc1 (2020-08-16 13:04:57 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/rppt/memblock.git tags/fixes-2020-08-18

for you to fetch changes up to bd05220c7be3356046861c317d9c287ca50445ba:

  arch/ia64: Restore arch-specific pgd_offset_k implementation (2020-08-17 21:50:54 +0300)

----------------------------------------------------------------
Fix regression in IA-64 caused by page table allocation refactoring

The refactoring and consolidation of <asm/pgalloc.h> caused regression
on parisc and ia64. The fix for parisc made it into v5.9-rc1 while the
fix ia64 got delayed a bit and here it is.

----------------------------------------------------------------
Jessica Clarke (1):
      arch/ia64: Restore arch-specific pgd_offset_k implementation

 arch/ia64/include/asm/pgtable.h | 9 +++++++++
 include/linux/pgtable.h         | 2 ++
 2 files changed, 11 insertions(+)

-- 
Sincerely yours,
Mike.
