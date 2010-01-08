From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 08 Jan 2010 23:55:41 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be  kernel-related?
Message-Id: <201001081655.41804.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Friday 08 January 2010 01:06:07 pm =C9meric Maschino wrote:
> Sure. Please find below the entire dmesg log with drm.debug=3D1 (BTW, is
> this the right way to post such a huge output to the list?):

This is perfect.

> [    0.705195] ioc_iova_init() IOV page size 16K pdir e000004080e80000 si=
ze 80000
> [    0.707381] IOC: reserving 512Mb of IOVA space at 0x60000000 for agpga=
rt
> [    0.707417] put cookie at 0xe000004080ec0000: 0xbadbadc0ffee
> [    0.707453] ioc_resource_init() res_size 0x1000
> [    0.707488] ioc_resource_init() res_map 1000 e000004080e2c000
> [    0.707525] IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000

> [   13.930385] Linux agpgart interface v0.103
> [   14.036636] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   14.036674] GART at 0xe000004080ec0000
> [   14.036706] read cookie at 0xe000004080ec0000: 0xbadbadc0ffee
> [   14.037359]  (null): AGP aperture is 512M @ 0x60000000

Perfectly normal so far.  We called hp_zx1_setup() and agp_add_bridge(),
which clears the GATT (in .create_gatt_table), which blows away the
cookie at gatt[0].

> [   14.037394] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   14.037429] GART at 0xe000004080ec0000
> [   14.037460] read cookie at 0xe000004080ec0000: 0x0
> [   14.037492] agpgart: No reserved IO PDIR entry found; GART disabled

Then for some reason we must be calling hp_zx1_setup() again, and this
time it failed because the cookie is gone.  This could happen if
agp_add_bridge() failed, but I don't see a way it could fail after
printing the "AGP aperture is 512M" message.

Can you try the attached patch, please?

Bjorn


commit 7beeef993b8b5c66084f5b025419914992101595
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Thu Jan 7 16:23:45 2010 -0700

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iomm=
u.c
index e14c492..8f205d8 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -95,7 +95,7 @@ extern int swiotlb_late_init_with_default_size (size_t si=
ze);
 ** longer guaranteed to stay in sync.  The sanity checking code isn't goin=
g to
 ** like that.
 */
-#undef DEBUG_SBA_INIT
+#define DEBUG_SBA_INIT
 #undef DEBUG_SBA_RUN
 #undef DEBUG_SBA_RUN_SG
 #undef DEBUG_SBA_RESOURCE
@@ -1656,11 +1656,15 @@ ioc_iova_init(struct ioc *ioc)
 	for_each_pci_dev(device)=09
 		agp_found |=3D pci_find_capability(device, PCI_CAP_ID_AGP);
=20
+	agp_found =3D 1;
 	if (agp_found && reserve_sba_gart) {
 		printk(KERN_INFO PFX "reserving %dMb of IOVA space at 0x%lx for agpgart\=
n",
 		      ioc->iov_size/2 >> 20, ioc->ibase + ioc->iov_size/2);
 		ioc->pdir_size /=3D 2;
 		((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)] =3D ZX1_SBA_IOMMU_C=
OOKIE;
+		printk("put cookie at 0x%p: 0x%llx\n",
+		       &((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)],
+		       ((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)]);
 	}
 #ifdef FULL_VALID_PDIR
 	/*
diff --git a/drivers/char/agp/backend.c b/drivers/char/agp/backend.c
index a56ca08..5a7a529 100644
--- a/drivers/char/agp/backend.c
+++ b/drivers/char/agp/backend.c
@@ -320,6 +320,7 @@ int agp_add_bridge(struct agp_bridge_data *bridge)
 	}
=20
 	list_add(&bridge->list, &agp_bridges);
+	printk("%s: returning 0 (success)\n", __func__);
 	return 0;
=20
 frontend_err:
@@ -327,6 +328,7 @@ frontend_err:
 err_out:
 	module_put(bridge->driver->owner);
 	agp_put_bridge(bridge);
+	printk("%s: returning %d (failure)\n", __func__, error);
 	return error;
 }
 EXPORT_SYMBOL_GPL(agp_add_bridge);
diff --git a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
index 58752b7..3a02bdb 100644
--- a/drivers/char/agp/hp-agp.c
+++ b/drivers/char/agp/hp-agp.c
@@ -110,6 +110,8 @@ static int __init hp_zx1_ioc_shared(void)
 	hp->io_pdir =3D phys_to_virt(readq(hp->ioc_regs+HP_ZX1_PDIR_BASE));
 	hp->gatt =3D &hp->io_pdir[HP_ZX1_IOVA_TO_PDIR(hp->gart_base)];
=20
+	printk("GART at 0x%p\n", hp->gatt);
+	printk("read cookie at 0x%p: 0x%llx\n", &hp->gatt[0], hp->gatt[0]);
 	if (hp->gatt[0] !=3D HP_ZX1_SBA_IOMMU_COOKIE) {
 		/* Normal case when no AGP device in system */
 		hp->gatt =3D NULL;
@@ -266,6 +268,7 @@ hp_zx1_cleanup (void)
 {
 	struct _hp_private *hp =3D &hp_private;
=20
+	printk("%s\n", __func__);
 	if (hp->ioc_regs) {
 		if (hp->io_pdir_owner) {
 			writeq(0, hp->ioc_regs+HP_ZX1_IBASE);
@@ -292,6 +295,7 @@ hp_zx1_create_gatt_table (struct agp_bridge_data *bridg=
e)
 	struct _hp_private *hp =3D &hp_private;
 	int i;
=20
+	printk("%s\n", __func__);
 	if (hp->io_pdir_owner) {
 		hp->io_pdir =3D (u64 *) __get_free_pages(GFP_KERNEL,
 						get_order(hp->io_pdir_size));
@@ -319,6 +323,7 @@ hp_zx1_free_gatt_table (struct agp_bridge_data *bridge)
 {
 	struct _hp_private *hp =3D &hp_private;
=20
+	printk("%s\n", __func__);
 	if (hp->io_pdir_owner)
 		free_pages((unsigned long) hp->io_pdir,
 			    get_order(hp->io_pdir_size));
@@ -465,6 +470,7 @@ hp_zx1_setup (u64 ioc_hpa, u64 lba_hpa)
 	bridge->dev =3D &fake_bridge_dev;
=20
 	error =3D agp_add_bridge(bridge);
+	printk("%s: agp_add_bridge returned %d\n", __func__, error);
   fail:
 	if (error)
 		hp_zx1_cleanup();
@@ -479,6 +485,7 @@ zx1_gart_probe (acpi_handle obj, u32 depth, void *conte=
xt, void **ret)
 	struct acpi_device_info *info;
 	u64 lba_hpa, sba_hpa, length;
 	int match;
+	int error;
=20
 	status =3D hp_acpi_csr_space(obj, &lba_hpa, &length);
 	if (ACPI_FAILURE(status))
@@ -511,7 +518,9 @@ zx1_gart_probe (acpi_handle obj, u32 depth, void *conte=
xt, void **ret)
 	if (ACPI_FAILURE(status))
 		return AE_OK;	/* found no enclosing IOC */
=20
-	if (hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa))
+	error =3D hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
+	printk("%s: hp_zx1_setup returned %d\n", __func__, error);
+	if (error)
 		return AE_OK;
=20
 	printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset "
@@ -525,6 +534,7 @@ zx1_gart_probe (acpi_handle obj, u32 depth, void *conte=
xt, void **ret)
 static int __init
 agp_hp_init (void)
 {
+	printk("%s\n", __func__);
 	if (agp_off)
 		return -EINVAL;
=20
