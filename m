From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Jul 2013 17:54:02 +0000
Subject: [GIT PULL] Fix ia64 build warnings
Message-Id: <51dafcba4543be3b6@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit d2b4a646717153a1a180b64d4a8464054dbd700e:

  Merge branch 'for-linus' of git://git.infradead.org/users/vkoul/slave-dma (2013-07-07 11:11:43 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-fix-ia64-warnings

for you to fetch changes up to 44840098478f6bf8c6e8d010241dcd4990fefe07:

  [IA64] sim: Add casts to avoid assignment warnings (2013-07-08 10:46:50 -0700)

----------------------------------------------------------------
Add some casts to avoid warnings from efi_runtime_services_t members.

----------------------------------------------------------------
Tony Luck (1):
      [IA64] sim: Add casts to avoid assignment warnings

 arch/ia64/hp/sim/boot/fw-emu.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)
