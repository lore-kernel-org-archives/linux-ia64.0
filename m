From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Wed, 22 Sep 2004 02:10:56 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[3/6]-Mapping lsapic to cpu
Message-Id: <20040922111056.3360443c.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com>
 <20040920093819.E14208@unix-os.sc.intel.com>
In-Reply-To: <20040920093819.E14208@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: tokunaga.keiich@jp.fujitsu.com, len.brown@intel.com, acpi-devel@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 20 Sep 2004 09:38:19 -0700 Keshavamurthy Anil S wrote:
> ---
> Name:acpi_hotplug_arch.patch
> Status: Tested on 2.6.9-rc2
> Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
> Depends:	
> Version: applies on 2.6.9-rc2	
> Description: 
> This patch provides the architecture specifice support for mapping lsapic to cpu array.
> Currently this supports just IA64. Support for IA32 and x86_64 is in progress
> ---

Here is a small fix.

Thanks,
Keiichiro Tokunaga


Name: pxm_to_nid_map_fix.patch
Status: Tested on 2.6.9-rc2
Signed-off-by: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Description:
Change an attribute of pxm_to_nid_map[] from __initdata to __devinitdata.

---

 linux-2.6.9-rc2-fix-kei/include/asm-ia64/acpi.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN include/asm-ia64/acpi.h~pxm_to_nid_map_fix include/asm-ia64/acpi.h
--- linux-2.6.9-rc2-fix/include/asm-ia64/acpi.h~pxm_to_nid_map_fix	2004-09-22 09:30:17.692176696 +0900
+++ linux-2.6.9-rc2-fix-kei/include/asm-ia64/acpi.h	2004-09-22 09:30:17.694129834 +0900
@@ -101,7 +101,7 @@ int acpi_gsi_to_irq (u32 gsi, unsigned i
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
 #define MAX_PXM_DOMAINS (256)
-extern int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
+extern int __devinitdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
 #endif
 

_
