From: Alex Chiang <achiang@hp.com>
Date: Thu, 25 Feb 2010 21:09:46 +0000
Subject: [PATCH 0/2] Fix sim_defconfig build error
Message-Id: <20100225210802.23267.74096.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The first patch is required to fix a build error when building the
sim_defconfig.

The second patch is optional. It adds a little bloat to tiger and bigsur
defconfig, but I don't think it affects SGI or Fujitsu, since I think
they do turn on CONFIG_IA64_GENERIC, and thus will be a nop.

/ac

---

Alex Chiang (2):
      [IA64] only build arch/ia64/kernel/acpi.o when CONFIG_ACPI
      [IA64] build arch/ia64/kernel/acpi-ext.o when CONFIG_ACPI


 arch/ia64/include/asm/acpi.h |   25 +++++++++++++++++++++++++
 arch/ia64/kernel/Makefile    |    6 ++----
 arch/ia64/kernel/acpi.c      |   33 +--------------------------------
 arch/ia64/kernel/process.c   |    4 ++++
 4 files changed, 32 insertions(+), 36 deletions(-)

