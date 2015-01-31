From: Yijing Wang <wangyijing@huawei.com>
Date: Sat, 31 Jan 2015 00:55:42 +0000
Subject: Re: [PATCH v2 00/30] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <54CC280E.1040004@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com> <54CB4A96.1080008@huawei.com> <CAErSpo7EdJkxOq6f-1htW7LWDc42bVGqBDirzV6v=u5PxYo4tQ@mail.gmail.com>
In-Reply-To: <CAErSpo7EdJkxOq6f-1htW7LWDc42bVGqBDirzV6v=u5PxYo4tQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On 2015/1/30 23:45, Bjorn Helgaas wrote:
> On Fri, Jan 30, 2015 at 3:10 AM, Yijing Wang <wangyijing@huawei.com> wrot=
e:
>> Hi Bjorn,
>>    Any comments for this series ?  I'm so sorry to bother you.  :)
>=20
> It's next in my queue after Wei Yang's powerpc sriov series.  Here's
> the queue I work from:
> https://patchwork.ozlabs.org/project/linux-pci/list/?order=DAte

OK, thanks.

>=20
> Bjorn
>=20
>> On 2015/1/21 8:29, Yijing Wang wrote:
>>> v1->v2:
>>>       Split pci_host_bridge_list into a new patch, remove .phb_probe_mo=
de
>>>       and rework powerpc .phb_of_scan_bus() for simpilicty suggested by
>>>       Arnd. Refresh some patch description log, and add a new patch to =
fix
>>>       build warning in ia64.
>>>
>>> This series is based on Bjorn's pci-next branch.
>>>
>>> Patch 1-4 ripped out pci_bus_add_devices() from pci scan interfaces
>>> for better pci scan flow.
>>>
>>> Patch 5-11 make a generic pci_host_bridge to hold pci_host_bridge
>>> related informations, and introduce a pci_host_bridge_ops to
>>> support platform host drivers provide its own pci_host_bridge
>>> related operations to setup pci_host_bridge during pci enumeration.
>>>
>>> Patch 12-28 apply the new pci scan interfaces to platform pci host
>>> bridge drivers.
>>>
>>> Now in kernel, we scan pci bus use the following ways:
>>> 1. pci_scan_bus.
>>>       parent =3D NULL, default io/mem/bus resources
>>>       call pci_bus_add_devices()
>>>
>>> 2. pci_scan_bus_parented() + pci_bus_add_devices()
>>>       default io/mem/bus resources, only used by xen
>>>
>>> 3. pci_scan_root_bus() + pci_bus_add_devices()
>>>
>>> 4. pci_create_root_bus() + pci_scan_child_bus() + pci_bus_add_devices()
>>>
>>> 5. pci_create_root_bus() + xx_of_scan_bus()  +  pci_bus_add_devices()
>>>
>>> And we have a lot of arch specific pci_domain_nr() and other platform
>>> specific weak function like pcibios_root_bridge_prepare().
>>>
>>> After applied this series, we have following scan interfaces:
>>>
>>> 1. pci_scan_bus_legacy()
>>>       parent =3D NULL, default io/mem/bus resources.
>>>       for legacy pci scan
>>>
>>> 2. pci_scan_root_bus()
>>>       for callers provide its own parent and io/mem/bus resources
>>>       but no platform specific pci_host_bridge operations
>>>
>>> 3. pci_scan_root_bridge()
>>>       for callers provide its own parent and io/mem/bus resources
>>>       and pci_host_bridge_ops.
>>>
>>> Besides, above pci scan interfaces all need addtionally call pci_bus_ad=
d_devices()
>>> to set match_driver true and try to attach drivers.
>>>
>>> Also we could eliminate all arch specific pci_domain_nr() after applied=
 this series.
>>>
>>> I tested this series on x86 (with or without ACPI).
>>> Comments and tests are warmly welcome!
>>>
>>> Arnd Bergmann (1):
>>>   xen/PCI: Don't use deprecated function pci_scan_bus_parented()
>>>
>>> Yijing Wang (29):
>>>   PCI: Rip out pci_bus_add_devices() from pci_scan_bus()
>>>   PCI: Rip out pci_bus_add_devices() from pci_scan_root_bus()
>>>   PCI: Remove deprecated pci_scan_bus_parented()
>>>   PCI: Rename pci_scan_bus() to pci_scan_bus_legacy()
>>>   PCI: Combine PCI domain and bus number in u32 arg
>>>   PCI: Pass PCI domain number combined with root bus number
>>>   PCI: Introduce pci_host_assign_domain_nr() to assign domain
>>>   PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
>>>   PCI: Introduce pci_host_bridge_list to manage host bridges
>>>   PCI: Save sysdata in pci_host_bridge drvdata
>>>   PCI: Introduce pci_host_bridge_ops to support host specific
>>>     operations
>>>   PCI: Introduce new scan function pci_scan_root_bridge()
>>>   PCI/x86: Refine pci_acpi_scan_root() with generic pci_host_bridge
>>>   PCI/IA64: Refine pci_acpi_scan_root() with generic pci_host_bridge
>>>   PCI/IA64: Fix the build warning about pci_domain_nr()
>>>   PCI/powerpc: Rename pcibios_root_bridge_prepare()
>>>   PCI/powerpc: Use pci_scan_root_bridge() for simplicity
>>>   PCI: Remove weak pcibios_root_bridge_prepare()
>>>   PCI/sparc: Use pci_scan_root_bridge() for simplicity
>>>   PCI: Introduce pci_bus_child_max_busnr()
>>>   PCI/Parisc: Use pci_scan_root_bus() for simplicity
>>>   PCI/mvebu: Use pci_common_init_dev() to simplify code
>>>   PCI/tegra: Remove redundant tegra_pcie_scan_bus()
>>>   PCI/designware: Use pci_scan_root_bus() for simplicity
>>>   PCI/xgene: Use pci_scan_root_bus() instead of pci_create_root_bus()
>>>   PCI: Rename __pci_create_root_bus() to pci_create_root_bus()
>>>   PCI: Export find_pci_host_bridge()
>>>   PCI: Remove platform specific pci_domain_nr()
>>>   PCI: Remove pci_bus_assign_domain_nr()
>>>
>>>  arch/alpha/include/asm/pci.h             |    2 -
>>>  arch/alpha/kernel/pci.c                  |    7 +-
>>>  arch/alpha/kernel/sys_nautilus.c         |    4 +-
>>>  arch/frv/mb93090-mb00/pci-vdk.c          |    6 +-
>>>  arch/ia64/include/asm/pci.h              |    1 -
>>>  arch/ia64/pci/pci.c                      |   34 +++---
>>>  arch/ia64/sn/kernel/io_acpi_init.c       |    6 +-
>>>  arch/ia64/sn/kernel/io_init.c            |    8 +-
>>>  arch/m68k/coldfire/pci.c                 |    3 +-
>>>  arch/microblaze/pci/pci-common.c         |   17 +--
>>>  arch/mips/include/asm/pci.h              |    2 -
>>>  arch/mips/pci/pci.c                      |    5 +-
>>>  arch/mn10300/unit-asb2305/pci.c          |    5 +-
>>>  arch/powerpc/include/asm/machdep.h       |    2 +-
>>>  arch/powerpc/kernel/pci-common.c         |   77 ++++++------
>>>  arch/powerpc/platforms/pseries/pci.c     |    8 +-
>>>  arch/powerpc/platforms/pseries/pseries.h |    2 +-
>>>  arch/powerpc/platforms/pseries/setup.c   |    2 +-
>>>  arch/s390/pci/pci.c                      |   13 +--
>>>  arch/sh/drivers/pci/pci.c                |    6 +-
>>>  arch/sh/include/asm/pci.h                |    2 -
>>>  arch/sparc/kernel/leon_pci.c             |    1 +
>>>  arch/sparc/kernel/pci.c                  |   50 ++++----
>>>  arch/sparc/kernel/pcic.c                 |    4 +-
>>>  arch/tile/include/asm/pci.h              |    2 -
>>>  arch/tile/kernel/pci.c                   |    6 +-
>>>  arch/tile/kernel/pci_gx.c                |    7 +-
>>>  arch/unicore32/kernel/pci.c              |   13 +--
>>>  arch/x86/include/asm/pci.h               |    6 -
>>>  arch/x86/pci/acpi.c                      |   38 +++---
>>>  arch/x86/pci/common.c                    |    4 +-
>>>  arch/xtensa/kernel/pci.c                 |    2 +
>>>  drivers/parisc/dino.c                    |   11 +--
>>>  drivers/parisc/lba_pci.c                 |    7 +-
>>>  drivers/pci/host-bridge.c                |   90 ++++++++++++++-
>>>  drivers/pci/host/pci-mvebu.c             |   18 +---
>>>  drivers/pci/host/pci-tegra.c             |   16 ---
>>>  drivers/pci/host/pci-xgene.c             |    3 +-
>>>  drivers/pci/host/pcie-designware.c       |    4 +-
>>>  drivers/pci/hotplug/acpiphp_glue.c       |   29 +-----
>>>  drivers/pci/hotplug/ibmphp_core.c        |    6 +-
>>>  drivers/pci/pci.c                        |   42 ++++++-
>>>  drivers/pci/probe.c                      |  196 ++++++++++++----------=
--------
>>>  drivers/pci/xen-pcifront.c               |   11 ++-
>>>  include/linux/pci.h                      |   47 +++++---
>>>  include/uapi/linux/pci.h                 |    3 +
>>>  46 files changed, 424 insertions(+), 404 deletions(-)
>>>
>>>
>>> .
>>>
>>
>>
>> --
>> Thanks!
>> Yijing
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> .
>=20


--=20
Thanks!
Yijing

