From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Nov 2008 12:59:50 +0000
Subject: [PATCH 0/5] ia64/pv_ops, xen: binary patch optimization
Message-Id: <1227618235-3890-1-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch set is for binary patch optimization for paravirt_ops.
The binary patch optimization is important on native case because
the paravirt_ops overhead can be reduced by converting indirect 
call into in-place execution or direct call.


The first patch imports helper functions which themselves doesn't interesting
things.
The second patch replaces the indirect function calls with a special
call written in gcc extended inline asm and introduces native methods.
The third patch introduces binary patch for kernel modules.
The forth patch suppress false positive warnings which were caused by
the previous patches.
The last patch implements xen methods.


For convenience the working full source is available from
http://people.valinux.co.jp/~yamahata/xen-ia64/for_eagl/linux-2.6-ia64-pv-ops.git/
branch: ia64-pv-ops-2008nov25-xen-ia64-optimized-domu-binary-patch

For the status of this patch series
http://wiki.xensource.com/xenwiki/XenIA64/UpstreamMerge

thanks,

Diffstat:
 arch/ia64/include/asm/intrinsics.h      |    6 +-
 arch/ia64/include/asm/module.h          |    6 +
 arch/ia64/include/asm/paravirt.h        |    8 +
 arch/ia64/include/asm/paravirt_patch.h  |  143 +++++++
 arch/ia64/include/asm/paravirt_privop.h |  347 ++++++++++++++++-
 arch/ia64/include/asm/xen/privop.h      |    4 +
 arch/ia64/kernel/Makefile               |    3 +-
 arch/ia64/kernel/efi.c                  |    1 +
 arch/ia64/kernel/module.c               |   32 ++
 arch/ia64/kernel/paravirt.c             |  520 ++++++++++++++++++++++++-
 arch/ia64/kernel/paravirt_patch.c       |  509 +++++++++++++++++++++++
 arch/ia64/kernel/paravirtentry.S        |  101 ++++-
 arch/ia64/kernel/setup.c                |    1 +
 arch/ia64/kernel/vmlinux.lds.S          |   24 ++
 arch/ia64/kvm/vtlb.c                    |    2 +
 arch/ia64/xen/hypercall.S               |    2 +
 arch/ia64/xen/xen_pv_ops.c              |  667 +++++++++++++++++++++++++++++++
 17 files changed, 2351 insertions(+), 25 deletions(-)
