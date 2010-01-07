From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 07 Jan 2010 23:57:00 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be  kernel-related?
Message-Id: <201001071657.00754.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thursday 07 January 2010 04:02:37 pm =C9meric Maschino wrote:
> All,
>=20
> I've successfully recompiled 2.6.33-rc3 kernel with the following
> patches from Bjorn Helgaas (thank you!):
> - [PATCH 1/2] ACPICA: acpi_get_object_info(): fixup array -> pointer
> () (http://marc.info/?l=3Dlinux-ia64&m=126289433630090&w=3D2)
> - [PATCH 2/2] agp/hp: fail gracefully if we don't find an IOC
> (http://marc.info/?l=3Dlinux-ia64&m=126289434030106&w=3D2).
>=20
> I'm still getting the reported drm_mmap_locked error, but now that
> Bjorn fixed the kernel crash in the hp-agp driver ([PATCH 0/2] agp/hp:
> fix zx1_gart_probe oops
> (http://marc.info/?l=3Dlinux-ia64&m=126289433530083&w=3D2)), dmesg output
> is more verbose:

Thanks a lot for testing these patches!

> [   14.206257] Linux agpgart interface v0.103
> [   14.315142] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   14.315522]  (null): AGP aperture is 512M @ 0x60000000
> [   14.315557] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   14.315592] agpgart: No reserved IO PDIR entry found; GART disabled

Huh, something strange is going on.  On these machines, when we find an
AGP-capable device, we use part of an IOMMU to implement the GART.  We
must have found an AGP device, because the IOMMU has 1G of address
space, and you can see that half of it is reserved for the GART.

The IOMMU driver puts a magic cookie at the beginning of the reserved
area, and the hp-agp driver looks for it.  On your system, it looks
like we reserved the space (and presumably installed the cookie), but
hp-agp didn't find it.  I don't have an AGP device in my box, but I
forced that path on by hand, and I get this, which looks correct:

  IOC: reserving 512Mb of IOVA space at 0x60000000 for agpgart
  IOC: zx1 2.2 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
  agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
   (null): AGP aperture is 512M @ 0x60000000
  agpgart: Detected HP ZX1 HWP0003 AGP chipset (ioc=FEd01000, lba=FEd28000)

Can you try the debug patch below, and respond with the entire dmesg
log and the output of "lspci -vv"?

Bjorn


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
diff --git a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
index 58752b7..ff4d4a6 100644
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
