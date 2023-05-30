From: Luis Chamberlain <mcgrof@kernel.org>
Date: Tue, 30 May 2023 16:34:23 +0000
Subject: [GIT PULL] Modules changes for v6.4-rc5
Message-Id: <ZHYlj7jks1GIxNSn@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-modules@vger.kernel.org, linux-ia64@vger.kernel.org, debian-ia64@lists.debian.org, glaubitz@physik.fu-berlin.de, Frank Scheiner <frank.scheiner@web.de>, Song Liu <song@kernel.org>, mcgrof@kernel.org

The following changes since commit d36f6efbe0cb422fe1e4475717d75f3737088832:

  module: Fix use-after-free bug in read_file_mod_stats() (2023-05-22 14:13:13 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/ tags/modules-6.4-rc5

for you to fetch changes up to db3e33dd8bd956f165436afdbdbf1c653fb3c8e6:

  module: fix module load for ia64 (2023-05-30 09:29:40 -0700)

----------------------------------------------------------------
modules-6.4-rc5

A fix is provided for ia64. Even though ia64 is on life support it helps
to fix issues if we can. Thanks to Linus for doing tons of the ia64
debugging.

----------------------------------------------------------------
Song Liu (1):
      module: fix module load for ia64

 kernel/module/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
