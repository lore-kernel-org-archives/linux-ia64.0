From: Ashok Raj <ashok.raj@intel.com>
Date: Fri, 28 Jan 2005 20:53:01 +0000
Subject: patch to fix recent percpu mca changes which broke CPU hotplug
Message-Id: <20050128125301.A16685@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony

Recent mca percpu changes broke a cpu being brought up after initial boot
which is required for cpu hotplug.

trivial patch 

-- 
Cheers,
Ashok Raj



---

Signed-off-by: Ashok Raj <ashok.raj@intel.com>

Tried booting with maxcpus=1 and then try to bring the other cpu's up
by echoing to online file.
---

 linux-ia64-release-2.6.11-araj/arch/ia64/kernel/mca.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/kernel/mca.c~fix_mca_init arch/ia64/kernel/mca.c
--- linux-ia64-release-2.6.11/arch/ia64/kernel/mca.c~fix_mca_init	2005-01-28 12:11:24.627261951 -0800
+++ linux-ia64-release-2.6.11-araj/arch/ia64/kernel/mca.c	2005-01-28 12:24:52.657525490 -0800
@@ -1204,7 +1204,7 @@ static struct irqaction mca_cpep_irqacti
 
 /* Do per-CPU MCA-related initialization.  */
 
-void __init
+void __devinit
 ia64_mca_cpu_init(void *cpu_data)
 {
 	void *pal_vaddr;
_
