From: Christoph Egger <siccegge@cs.fau.de>
Date: Mon, 28 Jun 2010 13:40:26 +0000
Subject: [PATCH 0/2] Removing dead code
Message-Id: <cover.1277731915.git.siccegge@cs.fau.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi all!

        As part of the VAMOS[0] research project at the University of
Erlangen we are looking at multiple integrity errors in linux'
configuration system.

	I've been running a check on the arch/ia64 sourcetree for
config Items not defined in Kconfig and found 2 such cases. Sourcecode
blocks depending on these Items are not reachable from a vanilla
kernel -- dead code. I've seen such dead blocks made on purpose
e.g. while integrating new features into the kernel but generally
they're just useless.

	Each of the patches in this patchset removes on such dead
config Item, I'd be glad if you consider applying them. I've been
doing deeper analysis of such issues before and can do so again but
I'm not so sure they were fastly usefull.

        Please keep me informed of this patch getting confirmed /
merged so we can keep track of it.

Regards

        Christoph Egger

[0] http://vamos1.informatik.uni-erlangen.de/

Christoph Egger (2):
  Removing dead CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK
  Removing dead CONFIG_IOMMU_DEBUG

 arch/ia64/include/asm/native/inst.h |   96 ++++++++--------------------------
 arch/ia64/kernel/pci-dma.c          |    4 --
 2 files changed, 23 insertions(+), 77 deletions(-)

