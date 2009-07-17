From: Fenghua Yu <fenghua.yu@intel.com>
Date: Fri, 17 Jul 2009 18:11:46 +0000
Subject: [git pull] ia64 changes
Message-Id: <20090717181146.GA21129@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

While Tony is taking sabbatical, I'm IA64 co-maintainer (see MAINTAINERS).

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/fyu/linux-2.6.git release

This will update the files shown below.

Thanks!

-Fenghua

 arch/ia64/include/asm/fpu.h            |    2 ++
 arch/ia64/include/asm/xen/hypervisor.h |    1 +
 arch/ia64/kernel/dma-mapping.c         |    8 ++++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

Aurelien Jarno (1):
      Revert "Neither asm/types.h nor linux/types.h is required for arch/ia64/include/asm/fpu.h"

Fenghua Yu (1):
      Fix ia64 compilation IS_ERR and PTE_ERR errors.

fujita (1):
      Add dma_debug_init() for ia64

