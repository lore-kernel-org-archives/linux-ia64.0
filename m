From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Mon, 30 Jun 2014 17:52:57 +0000
Subject: [PATCH v7 03/10] arch/x86: Do not access EFI memory map if it is not available
Message-Id: <1404150784-27921-4-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

Do not access EFI memory map if it is not available. At least
Xen dom0 EFI implementation does not have an access to it.

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
---
v6 - suggestions/fixes:
   - create this separate patch from main EFI_PARAVIRT patch
     (suggested by Matt Fleming).
---
 arch/x86/platform/efi/efi.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 0ee1f46..d2d3c41 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -1220,6 +1220,9 @@ u64 efi_mem_attributes(unsigned long phys_addr)
 	efi_memory_desc_t *md;
 	void *p;
 
+	if (!efi_enabled(EFI_MEMMAP))
+		return 0;
+
 	for (p = memmap.map; p < memmap.map_end; p += memmap.desc_size) {
 		md = p;
 		if ((md->phys_addr <= phys_addr) &&
-- 
1.7.10.4

