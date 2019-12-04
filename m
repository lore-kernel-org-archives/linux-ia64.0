From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 04 Dec 2019 18:23:27 +0000
Subject: [GIT PULL] ia64 changes for v5.5
Message-Id: <20191204182327.GA17103@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The following changes since commit 219d54332a09e8d8741c1e1982f5eae56099de85:

  Linux 5.4 (2019-11-24 16:32:01 -0800)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-5.5

for you to fetch changes up to 240b62d381fe5b66c496a6fd55edff3976a9be51:

  ia64: remove stale paravirt leftovers (2019-12-02 14:18:12 -0800)

----------------------------------------------------------------
Cleanup some leftover para-virtualization pieces

----------------------------------------------------------------
Juergen Gross (1):
      ia64: remove stale paravirt leftovers

 arch/ia64/include/asm/irqflags.h          |  4 ---
 arch/ia64/include/uapi/asm/gcc_intrin.h   | 24 +++++++--------
 arch/ia64/include/uapi/asm/intel_intrin.h | 32 +++++++++----------
 arch/ia64/include/uapi/asm/intrinsics.h   | 51 ++++---------------------------
 4 files changed, 34 insertions(+), 77 deletions(-)
