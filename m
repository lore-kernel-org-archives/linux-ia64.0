From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:41:18 +0000
Subject: [PATCH 4/5] ia64/pv_ops/binary patch: define paravirt_dv_serialize_data() and suppress false positiv
Message-Id: <1229064079-27735-5-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1227618235-3890-5-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1227618235-3890-5-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define paravirt_dv_serialize_data() and insert it to suppress
false positive warnings.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/paravirt_privop.h |    6 ++++++
 arch/ia64/kernel/efi.c                  |    1 +
 arch/ia64/kvm/vtlb.c                    |    2 ++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/paravirt_privop.h b/arch/ia64/include/asm/paravirt_privop.h
index 76d6a69..4e40e62 100644
--- a/arch/ia64/include/asm/paravirt_privop.h
+++ b/arch/ia64/include/asm/paravirt_privop.h
@@ -118,6 +118,12 @@ void paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch);
 
 #endif /* CONFIG_PARAVIRT */
 
+#if defined(CONFIG_PARAVIRT) && defined(ASM_SUPPORTED)
+#define paravirt_dv_serialize_data()	ia64_dv_serialize_data()
+#else
+#define paravirt_dv_serialize_data()	/* nothing */
+#endif
+
 /* these routines utilize privilege-sensitive or performance-sensitive
  * privileged instructions so the code must be replaced with
  * paravirtualized versions */
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index efaff15..7ef80e8 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -456,6 +456,7 @@ efi_map_pal_code (void)
 		 GRANULEROUNDDOWN((unsigned long) pal_vaddr),
 		 pte_val(pfn_pte(__pa(pal_vaddr) >> PAGE_SHIFT, PAGE_KERNEL)),
 		 IA64_GRANULE_SHIFT);
+	paravirt_dv_serialize_data();
 	ia64_set_psr(psr);		/* restore psr */
 }
 
diff --git a/arch/ia64/kvm/vtlb.c b/arch/ia64/kvm/vtlb.c
index e22b933..500c878 100644
--- a/arch/ia64/kvm/vtlb.c
+++ b/arch/ia64/kvm/vtlb.c
@@ -210,6 +210,7 @@ void thash_vhpt_insert(struct kvm_vcpu *v, u64 pte, u64 itir, u64 va, int type)
 		phy_pte  &= ~PAGE_FLAGS_RV_MASK;
 		psr = ia64_clear_ic();
 		ia64_itc(type, va, phy_pte, itir_ps(itir));
+		paravirt_dv_serialize_data();
 		ia64_set_psr(psr);
 	}
 
@@ -464,6 +465,7 @@ int thash_purge_and_insert(struct kvm_vcpu *v, u64 pte, u64 itir,
 		phy_pte  &= ~PAGE_FLAGS_RV_MASK;
 		psr = ia64_clear_ic();
 		ia64_itc(type, ifa, phy_pte, ps);
+		paravirt_dv_serialize_data();
 		ia64_set_psr(psr);
 	}
 	if (!(pte&VTLB_PTE_IO))
-- 
1.6.0.2

