From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Jul 2007 23:40:57 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A0209BBD8@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.  The fs/quota.c change (together with
the changes to arch/{ia64,x86_64}/Kconfig solve a build problem when CONFIG_COMPAT=n
(discussed to death on LKML/linux-arch in the "build fix for x86_64" thread).

Thanks!

-Tony

 arch/ia64/Kconfig               |    3 +++
 arch/ia64/hp/common/sba_iommu.c |    7 ++++++-
 arch/ia64/hp/sim/simscsi.c      |    2 +-
 arch/ia64/kernel/acpi.c         |    9 ++++-----
 arch/ia64/kernel/irq_ia64.c     |    5 ++++-
 arch/x86_64/Kconfig             |    3 +++
 fs/quota.c                      |    2 +-
 7 files changed, 22 insertions(+), 9 deletions(-)

Kenji Kaneshige (3):
      [IA64] Add sanity check into __bind_irq_vector
      [IA64] Fix wrong assumption in acpi_gsi_to_irq
      [IA64] Fix wrong return value in parse_vector_domain

Thomas Renninger (1):
      [IA64] Use new acpi_device_id struct for HID init in ia64/hp/common/sba_iommu.c

Tony Luck (1):
      [IA64] Fix build failure in fs/quota.c

Yoann Padioleau (1):
      [IA64] Compare pointer against NULL, not '0'
