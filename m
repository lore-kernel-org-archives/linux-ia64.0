From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 May 2016 19:00:19 +0000
Subject: [GIT PULL] ia64 bits for 4.7
Message-Id: <573e0d431594818d2e@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 04974df8049fc4240d22759a91e035082ccd18b4:

  Linux 4.6-rc6 (2016-05-01 15:52:31 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-4.7

for you to fetch changes up to 787ca32dc704bde981760de01a3a7e6ce9835fdb:

  ia64/unaligned: Silence another GCC warning about an uninitialised variable (2016-05-05 10:29:14 -0700)

----------------------------------------------------------------
A bunch of cleanups from Matt and some dead code removal from Anna-Maria

----------------------------------------------------------------
Anna-Maria Gleixner (1):
      ia64: Remove superfluous SMP function call

Matt Fleming (5):
      ia64/PCI: Fix incorrect PCI resource end address
      ia64/PCI: Remove unused 'addr' and fix build warning
      ia64: Reduce stack usage by iterating over nodemask
      ia64/traps: Silence GCC warning about uninitialised variable
      ia64/unaligned: Silence another GCC warning about an uninitialised variable

 arch/ia64/kernel/mca.c             |  5 +----
 arch/ia64/kernel/traps.c           |  1 +
 arch/ia64/kernel/unaligned.c       |  1 +
 arch/ia64/sn/kernel/io_acpi_init.c |  1 -
 arch/ia64/sn/kernel/io_init.c      |  4 ++--
 arch/ia64/sn/kernel/sn2/sn2_smp.c  | 35 +++++++++++++++++++++++------------
 6 files changed, 28 insertions(+), 19 deletions(-)
