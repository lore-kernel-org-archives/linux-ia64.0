From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 09 Jul 2009 07:12:48 +0000
Subject: [PATCH v2 3/7] ia64, kexec: Unregister MCA handler before kexec
Message-Id: <4A559870.7090801@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A39E247.4030908@jp.fujitsu.com> <4A5595F3.2050609@jp.fujitsu.com>
In-Reply-To: <4A5595F3.2050609@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, kexec@lists.infradead.org, "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>

Summary:

  MCA on the beginning of kdump/kexec kernel will result in unexpected
  behavior because MCA handler for previous kernel is invoked on the
  kdump kernel.

Description:

  Once a cpu is passed to new kernel, all resources in previous kernel
  should not be used from the cpu.  Even the resources for MCA handler
  are no exception.  So we cannot handle MCAs and its machine check
  errors during kernel transition, until new handler for new kernel is
  registered with new resources ready for handling the MCA.

How to reproduce:

  Assert MCA while kdump kernel is booting, before new MCA handler for
  kdump kernel is registered.

Expected(Desirable) results:

  No recovery, cancel kdump and reboot the system.

Actual results:

  MCA handler for previous kernel is invoked on the kdump kernel.
  => panic, hang etc. (unexpected)

Proposed fix:

  To avoid entering MCA handler from early stage of new kernel,
  unregister the entry point from SAL before leave from current
  kernel.  Then SAL will make all MCAs to warmboot safely, without
  invoking OS_MCA.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Haren Myneni <hbabu@us.ibm.com>
Cc: kexec@lists.infradead.org
---
 arch/ia64/kernel/machine_kexec.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 571d663..3d3aeef 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -104,6 +104,9 @@ static void ia64_machine_kexec(struct unw_frame_info *info, void *arg)
 		ia64_sal_set_vectors(SAL_VECTOR_OS_INIT, 0, 0, 0, 0, 0, 0);
 	}
 
+	/* Unregister mca handler - No more recovery on current kernel */
+	ia64_sal_set_vectors(SAL_VECTOR_OS_MCA, 0, 0, 0, 0, 0, 0);
+
 	/* Interrupts aren't acceptable while we reboot */
 	local_irq_disable();
 
-- 
1.6.0


