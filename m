From: David Hildenbrand <david@redhat.com>
Date: Mon, 14 Sep 2020 07:57:46 +0000
Subject: Re: [PATCH 2/3] mm: don't rely on system state to detect hot-plug operations
Message-Id: <f50fe4ae-faf0-6e03-b87e-45ca8c53960d@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-3-ldufour@linux.ibm.com>
In-Reply-To: <20200911134831.53258-3-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On 11.09.20 15:48, Laurent Dufour wrote:
> In register_mem_sect_under_node() the system_state=E2=80=99s value is che=
cked to
> detect whether the operation the call is made during boot time or during =
an
> hot-plug operation. Unfortunately, that check against SYSTEM_BOOTING is
> wrong because regular memory is registered at SYSTEM_SCHEDULING state. In
> addition memory hot-plug operation can be triggered at this system state
> too by the ACPI. So checking against the system state is not enough.
>=20
> The consequence is that on system with interleaved node's ranges like thi=
s:
>  Early memory node ranges
>    node   1: [mem 0x0000000000000000-0x000000011fffffff]
>    node   2: [mem 0x0000000120000000-0x000000014fffffff]
>    node   1: [mem 0x0000000150000000-0x00000001ffffffff]
>    node   0: [mem 0x0000000200000000-0x000000048fffffff]
>    node   2: [mem 0x0000000490000000-0x00000007ffffffff]
>=20
> This can be seen on PowerPC LPAR after multiple memory hot-plug and
> hot-unplug operations are done. At the next reboot the node's memory rang=
es
> can be interleaved and since the call to link_mem_sections() is made in
> topology_init() while the system is in the SYSTEM_SCHEDULING state, the
> node's id is not checked, and the sections registered to multiple nodes:
>=20
> $ ls -l /sys/devices/system/memory/memory21/node*
> total 0
> lrwxrwxrwx 1 root root     0 Aug 24 05:27 node1 -> ../../node/node1
> lrwxrwxrwx 1 root root     0 Aug 24 05:27 node2 -> ../../node/node2
>=20
> In that case, the system is able to boot but if later one of theses memory
> block is hot-unplugged and then hot-plugged, the sysfs inconsistency is
> detected and triggered a BUG_ON():
>=20
> ------------[ cut here ]------------
> kernel BUG at /Users/laurent/src/linux-ppc/mm/memory_hotplug.c:1084!
> Oops: Exception in kernel mode, sig: 5 [#1]
> LE PAGE_SIZEdK MMU=3DHash SMP NR_CPUS 48 NUMA pSeries
> Modules linked in: rpadlpar_io rpaphp pseries_rng rng_core vmx_crypto gf1=
28mul binfmt_misc ip_tables x_tables xfs libcrc32c crc32c_vpmsum autofs4
> CPU: 8 PID: 10256 Comm: drmgr Not tainted 5.9.0-rc1+ #25
> NIP:  c000000000403f34 LR: c000000000403f2c CTR: 0000000000000000
> REGS: c0000004876e3660 TRAP: 0700   Not tainted  (5.9.0-rc1+)
> MSR:  800000000282b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE>  CR: 24000448  X=
ER: 20040000
> CFAR: c000000000846d20 IRQMASK: 0
> GPR00: c000000000403f2c c0000004876e38f0 c0000000012f6f00 ffffffffffffffef
> GPR04: 0000000000000227 c0000004805ae680 0000000000000000 00000004886f0000
> GPR08: 0000000000000226 0000000000000003 0000000000000002 fffffffffffffffd
> GPR12: 0000000088000484 c00000001ec96280 0000000000000000 0000000000000000
> GPR16: 0000000000000000 0000000000000000 0000000000000004 0000000000000003
> GPR20: c00000047814ffe0 c0000007ffff7c08 0000000000000010 c0000000013332c8
> GPR24: 0000000000000000 c0000000011f6cc0 0000000000000000 0000000000000000
> GPR28: ffffffffffffffef 0000000000000001 0000000150000000 0000000010000000
> NIP [c000000000403f34] add_memory_resource+0x244/0x340
> LR [c000000000403f2c] add_memory_resource+0x23c/0x340
> Call Trace:
> [c0000004876e38f0] [c000000000403f2c] add_memory_resource+0x23c/0x340 (un=
reliable)
> [c0000004876e39c0] [c00000000040408c] __add_memory+0x5c/0xf0
> [c0000004876e39f0] [c0000000000e2b94] dlpar_add_lmb+0x1b4/0x500
> [c0000004876e3ad0] [c0000000000e3888] dlpar_memory+0x1f8/0xb80
> [c0000004876e3b60] [c0000000000dc0d0] handle_dlpar_errorlog+0xc0/0x190
> [c0000004876e3bd0] [c0000000000dc398] dlpar_store+0x198/0x4a0
> [c0000004876e3c90] [c00000000072e630] kobj_attr_store+0x30/0x50
> [c0000004876e3cb0] [c00000000051f954] sysfs_kf_write+0x64/0x90
> [c0000004876e3cd0] [c00000000051ee40] kernfs_fop_write+0x1b0/0x290
> [c0000004876e3d20] [c000000000438dd8] vfs_write+0xe8/0x290
> [c0000004876e3d70] [c0000000004391ac] ksys_write+0xdc/0x130
> [c0000004876e3dc0] [c000000000034e40] system_call_exception+0x160/0x270
> [c0000004876e3e20] [c00000000000d740] system_call_common+0xf0/0x27c
> Instruction dump:
> 48442e35 60000000 0b030000 3cbe0001 7fa3eb78 7bc48402 38a5fffe 7ca5fa14
> 78a58402 48442db1 60000000 7c7c1b78 <0b030000> 7f23cb78 4bda371d 60000000
> ---[ end trace 562fd6c109cd0fb2 ]---
>=20
> This patch addresses the root cause by not relying on the system_state
> value to detect whether the call is due to a hot-plug operation. An extra
> parameter is needed in register_mem_sect_under_node() detailing whether t=
he
> operation is due to a hot-plug operation.
>=20
> Fixes: 4fbce633910e ("mm/memory_hotplug.c: make register_mem_sect_under_n=
ode() a callback of walk_memory_range()")
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> Cc: stable@vger.kernel.org
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/node.c  | 21 ++++++++++++++++-----
>  include/linux/node.h |  9 ++++++---
>  mm/memory_hotplug.c  |  3 ++-
>  3 files changed, 24 insertions(+), 9 deletions(-)
>=20
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 508b80f6329b..862516c5a5ae 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -762,14 +762,19 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
>  }
> =20
>  /* register memory section under specified node if it spans that node */
> +struct rmsun_args {
> +	int nid;
> +	enum memplug_context context;
> +};
>  static int register_mem_sect_under_node(struct memory_block *mem_blk,
> -					 void *arg)
> +					void *args)
>  {

Instead of handling this in register_mem_sect_under_node(), I
think it would be better two have two separate
register_mem_sect_under_node() implementations.

static int register_mem_sect_under_node_hotplug(struct memory_block *mem_bl=
k,
						void *arg)
{
	const int nid =3D *(int *)arg;
	int ret;

	/* Hotplugged memory has no holes and belongs to a single node. */
	mem_blk->nid =3D nid;
	ret =3D sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
				       &mem_blk->dev.kobj,
				       kobject_name(&mem_blk->dev.kobj));
	if (ret)
		returnr et;
	return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
					&node_devices[nid]->dev.kobj,
					kobject_name(&node_devices[nid]->dev.kobj));

}

Cleaner, right? :) No unnecessary checks.

One could argue if link_mem_section_hotplug() would be better than passing =
around the context.

--=20
Thanks,

David / dhildenb
