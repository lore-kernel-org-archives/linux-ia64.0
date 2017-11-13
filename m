From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Nov 2017 17:45:12 +0000
Subject: [GIT PULL] ia64 for v4.15
Message-Id: <20171113174503.meab66wclsmqrkdz@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 0b07194bb55ed836c2cc7c22e866b87a14681984:

  Linux 4.14-rc7 (2017-10-29 13:58:38 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-gettime_vsyscall_update

for you to fetch changes up to d4d1fc61eb38ff8e5af657e2d2f2290859a277f2:

  ia64: Update fsyscall gettime to use modern vsyscall_update (2017-10-31 10:58:36 -0700)

----------------------------------------------------------------
Stop ia64 being the last holdout using GENERIC_TIME_VSYSCALL_OLD
so John Stultz can drop that code.

----------------------------------------------------------------
Tony Luck (1):
      ia64: Update fsyscall gettime to use modern vsyscall_update

 arch/ia64/Kconfig                     |  2 +-
 arch/ia64/kernel/asm-offsets.c        |  2 ++
 arch/ia64/kernel/fsys.S               |  8 +++----
 arch/ia64/kernel/fsyscall_gtod_data.h | 10 +++++++--
 arch/ia64/kernel/time.c               | 40 ++++++++++++++++++-----------------
 5 files changed, 36 insertions(+), 26 deletions(-)
