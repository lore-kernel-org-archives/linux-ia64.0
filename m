From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Mar 2018 00:58:01 +0000
Subject: [GIT PULL] ia64 changes for 4.16
Message-Id: <20180306005800.dacsxozfjz2vhqk7@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 661e50bc853209e41a5c14a290ca4decc43cbfd1:

  Linux 4.16-rc4 (2018-03-04 14:54:11 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-ia64_misc

for you to fetch changes up to 48e362dd96f37d819042f848888b2c6407e01e6d:

  ia64/err-inject: fix spelling mistake: "capapbilities" -> "capabilities" (2018-03-05 14:44:53 -0800)

----------------------------------------------------------------
More atomic cleanup from willy. Fix a python script to work with version 3.
Some other small cleanups.

----------------------------------------------------------------
Colin Ian King (1):
      ia64/err-inject: fix spelling mistake: "capapbilities" -> "capabilities"

Corentin Labbe (1):
      ia64: convert unwcheck.py to python3

Davidlohr Bueso (1):
      ia64/err-inject: Use get_user_pages_fast()

Matthew Wilcox (1):
      ia64: Convert remaining atomic operations

Sergei Trofimovich (1):
      ia64: doc: tweak whitespace for 'console=' parameter

 Documentation/ia64/serial.txt  |  2 +-
 arch/ia64/include/asm/atomic.h | 69 ++++++++++++++----------------------------
 arch/ia64/kernel/err_inject.c  |  4 +--
 arch/ia64/scripts/unwcheck.py  | 16 +++++-----
 4 files changed, 34 insertions(+), 57 deletions(-)
