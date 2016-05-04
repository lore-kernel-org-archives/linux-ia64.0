From: Matt Fleming <matt@codeblueprint.co.uk>
Date: Wed, 04 May 2016 11:17:45 +0000
Subject: [PATCH 0/5] ia64: Fix compiler warnings
Message-Id: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>

I routinely build ia64 kernels when merging EFI patches and for a
while now I've seen a bunch of warnings from GCC.

These patches silence those warnings, with the first patch fixing an
actual bug but the rest just making GCC happier.

NOTE: None of these patches have been runtime tested.

Matt Fleming (5):
  ia64/PCI: Fix incorrect PCI resource end address
  ia64/PCI: Remove unused 'addr' and fix build warning
  ia64: Reduce stack usage by iterating over nodemask
  ia64/traps: Silence GCC warning about uninitialised variable
  ia64/unaligned: Silence another GCC warning about an uninitialised
    variable

 arch/ia64/kernel/traps.c           |  1 +
 arch/ia64/kernel/unaligned.c       |  1 +
 arch/ia64/sn/kernel/io_acpi_init.c |  1 -
 arch/ia64/sn/kernel/io_init.c      |  4 ++--
 arch/ia64/sn/kernel/sn2/sn2_smp.c  | 35 +++++++++++++++++++++++------------
 5 files changed, 27 insertions(+), 15 deletions(-)

-- 
2.7.3

