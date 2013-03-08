From: Hanjun Guo <guohanjun@huawei.com>
Date: Fri, 08 Mar 2013 04:33:35 +0000
Subject: [PATCH V2 2/2] ia64: iosapic: fix kexec oops when iosapic was removed
Message-Id: <1362717215-33904-1-git-send-email-guohanjun@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, Jianguo Wu <wujianguo@huawei.com>

Ioapic hotplug was supported in IA64 code, but will lead to kexec oops
when iosapic was removed. here is the code logic:

iosapic_remove
  iosapic_free
    memset(&iosapic_lists[index], 0, sizeof(iosapic_lists[0]))
      iosapic_lists[index].addr was set to 0;

and then kexec a new kernel
kexec_disable_iosapic
  iosapic_write(rte->iosapic,..)
    __iosapic_write(iosapic->addr, reg, val);
      addr was set to 0 when iosapic_remove, and oops happened

The call trace is:
Starting new kernel
kexec[11336]: Oops 8804682956800 [1]
Modules linked in: raw(N) ipv6(N) acpi_cpufreq(N) binfmt_misc(N) fuse(N) nl=
s_iso
8859_1(N) loop(N) ipmi_si(N) ipmi_devintf(N) ipmi_msghandler(N) mca_ereport=
(N) s
csi_ereport(N) nic_ereport(N) pcie_ereport(N) err_transport(N) nvlist(PN) d=
m_mod
(N) tpm_tis(N) tpm(N) ppdev(N) tpm_bios(N) serio_raw(N) i2c_i801(N) iTCO_wd=
t(N)
i2c_core(N) iTCO_vendor_support(N) sg(N) ioatdma(N) igb(N) mptctl(N) dca(N)=
 parp
ort_pc(N) parport(N) container(N) button(N) usbhid(N) hid(N) uhci_hcd(N) eh=
ci_hc
d(N) usbcore(N) sd_mod(N) crc_t10dif(N) ext3(N) mbcache(N) jbd(N) fan(N) pr=
ocess
or(N) ide_pci_generic(N) ide_core(N) ata_piix(N) libata(N) mptsas(N) mptscs=
ih(N)
 mptbase(N) scsi_transport_sas(N) scsi_mod(N) thermal(N) thermal_sys(N) hwm=
on(N)

Supported: Yes, External

Pid: 11336, CPU 0, comm:                kexec
psr : 0000101009522030 ifs : 8000000000000791 ip  : [<a00000010004c160>]   =
 Tain
ted: P          N  (2.6.32.12_RAS_V1R3C00B011)
ip is at kexec_disable_iosapic+0x120/0x1e0
unat: 0000000000000000 pfs : 0000000000000791 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 65519aa6a555a659
ldrs: 0000000000000000 ccv : 00000000ea3cf51e fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010004c150 b6  : a000000100012620 b7  : a00000010000cda0
f6  : 000000000000000000000 f7  : 1003e0000000002000000
f8  : 1003e0000000050000003 f9  : 1003e0000028fb97183cd
f10 : 1003ee9f380df3c548b67 f11 : 1003e00000000000000cc
r1  : a0000001016cf660 r2  : 0000000000000000 r3  : 0000000000000000
r8  : 0000001009526030 r9  : a000000100012620 r10 : e00000010053f600
r11 : c0000000fec34040 r12 : e00000078f76fd30 r13 : e00000078f760000
r14 : 0000000000000000 r15 : 0000000000000000 r16 : 0000000000000000
r17 : 0000000000000000 r18 : 0000000000007fff r19 : 0000000000000000
r20 : 0000000000000000 r21 : e00000010053f590 r22 : a000000100cf0000
r23 : 0000000000000036 r24 : e0000007002f8a84 r25 : 0000000000000022
r26 : e0000007002f8a88 r27 : 0000000000000020 r28 : 0000000000000002
r29 : a0000001012c8c60 r30 : 0000000000000000 r31 : 0000000000322e49

Call Trace:
 [<a000000100018ca0>] show_stack+0x80/0xa0
                                sp=E00000078f76f8f0 bsp=E00000078f761380
 [<a000000100019300>] show_regs+0x640/0x920
                                sp=E00000078f76fac0 bsp=E00000078f761328
 [<a00000010002a130>] die+0x190/0x2e0
                                sp=E00000078f76fad0 bsp=E00000078f7612e8
 [<a000000100922fa0>] ia64_do_page_fault+0x840/0xb20
                                sp=E00000078f76fad0 bsp=E00000078f761288
 [<a00000010000d5c0>] ia64_native_leave_kernel+0x0/0x270
                                sp=E00000078f76fb60 bsp=E00000078f761288
 [<a00000010004c160>] kexec_disable_iosapic+0x120/0x1e0
                                sp=E00000078f76fd30 bsp=E00000078f761200
 [<a000000100016970>] machine_shutdown+0x110/0x140
                                sp=E00000078f76fd30 bsp=E00000078f7611c8
 [<a000000100133530>] kernel_kexec+0xd0/0x120
                                sp=E00000078f76fd30 bsp=E00000078f7611a0
 [<a0000001000eca40>] sys_reboot+0x480/0x4e0
                                sp=E00000078f76fd30 bsp=E00000078f761128
 [<a00000010000d420>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000078f76fe30 bsp=E00000078f761120
Kernel panic - not syncing: Fatal exception

With Tony and Toshi's advice, the patch removes the "rte" from rte_list
when the iosapic was removed.

v2:
function name delete_rte_from_list was changed to iosapic_delete_rte with
Toshi's advice.

Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Acked-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/ia64/kernel/iosapic.c |   32 +++++++++++++++++++++++++++++++-
 1 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index a6e2f75..19f107b 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -1010,6 +1010,26 @@ iosapic_check_gsi_range (unsigned int gsi_base, unsi=
gned int ver)
 	return 0;
 }
=20
+static int
+iosapic_delete_rte(unsigned int irq, unsigned int gsi)
+{
+	struct iosapic_rte_info *rte, *temp;
+
+	list_for_each_entry_safe(rte, temp, &iosapic_intr_info[irq].rtes,
+								rte_list) {
+		if (rte->iosapic->gsi_base + rte->rte_index =3D gsi) {
+			if (rte->refcnt)
+				return -EBUSY;
+
+			list_del(&rte->rte_list);
+			kfree(rte);
+			return 0;
+		}
+	}
+
+	return -EINVAL;
+}
+
 int iosapic_init(unsigned long phys_addr, unsigned int gsi_base)
 {
 	int num_rte, err, index;
@@ -1069,7 +1089,7 @@ int iosapic_init(unsigned long phys_addr, unsigned in=
t gsi_base)
=20
 int iosapic_remove(unsigned int gsi_base)
 {
-	int index, err =3D 0;
+	int i, irq, index, err =3D 0;
 	unsigned long flags;
=20
 	spin_lock_irqsave(&iosapic_lock, flags);
@@ -1087,6 +1107,16 @@ int iosapic_remove(unsigned int gsi_base)
 		goto out;
 	}
=20
+	for (i =3D gsi_base; i < gsi_base + iosapic_lists[index].num_rte; i++) {
+		irq =3D __gsi_to_irq(i);
+		if (irq < 0)
+			continue;
+
+		err =3D iosapic_delete_rte(irq, i);
+		if (err)
+			goto out;
+	}
+
 	iounmap(iosapic_lists[index].addr);
 	iosapic_free(index);
  out:
--=20
1.6.0.2


