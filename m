From: domen@coderock.org
Date: Mon, 10 Jan 2005 19:46:31 +0000
Subject: [patch 1/3] Replace pci_find_device with pci_get_device
Message-Id: <20050110194632.475A61F203@trashy.coderock.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




As pci_find_device is going away soon I have replaced the call with pci_get_device.
Judith, could you run these 3 ia64 ones through PLM, please? This should complete the
arch/ia64 conversion.

Thanks a lot.

Hanna Linder
IBM Linux Technology Center

Signed-off-by: Hanna Linder <hannal@us.ibm.com>
Acked-by: Judith Lebzelter <judith@osdl.org>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/arch/ia64/hp/common/sba_iommu.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/hp/common/sba_iommu.c~pci_dev_present-arch_ia64_hp_common_sba_iommu arch/ia64/hp/common/sba_iommu.c
--- kj/arch/ia64/hp/common/sba_iommu.c~pci_dev_present-arch_ia64_hp_common_sba_iommu	2005-01-10 18:00:14.000000000 +0100
+++ kj-domen/arch/ia64/hp/common/sba_iommu.c	2005-01-10 18:00:14.000000000 +0100
@@ -1557,7 +1557,7 @@ ioc_iova_init(struct ioc *ioc)
 	** We program the next pdir index after we stop w/ a key for
 	** the GART code to handshake on.
 	*/
-	while ((device = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, device)) != NULL)
+	while ((device = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, device)) != NULL)
 		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
 
 	if (agp_found && reserve_sba_gart) {
_
