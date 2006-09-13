From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 13 Sep 2006 07:58:52 +0000
Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <08B1877B2880CE42811294894F33AD5C053C09@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Keith Owens
> Sent: 2006=C4=EA9=D4=C213=C8=D5 15:10
> To: Zou, Nanhai
> Cc: Takao Indoh; Yu, Luming; fastboot; Linux-IA64
> Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
>=20
> Zou Nan hai (on 11 Sep 2006 14:12:13 +0800) wrote:
> >	For 2.6 kernel, I think GP is a region 5 address when inside kernel.
> >The entire kernel image is resided in region 5 without relocate to
> >region 7.
>=20
> You are right, I have only three excuses.
>=20
> (1) Having too much fun skiing to think about computers.
> (2) The kernel _used_ to be in region 7.
> (3) The kernel addresses in region 5 can always be accessed via the
>     identity map in region 7 and sometimes we do just that, see below.
>=20
> >	Another issue I can see from calculate GP from physical address passed
> >from OS_INIT is,
> >	I am not quite sure though, if OS_INIT is happened during a module
> >execution, or happened when system is in user space, what GP value will
> >be passed from SAL/PAL? If the gp value is the physical address of the
> >modules 's gp, we can't set GP value according to that, because
> >ia64_init_handler is inside kernel.
>=20
> It does not matter where the kernel was when the INIT was delivered,
> even if the INIT ws delivered while a module was in control.  r1 must
> be loaded with the correct gp for the kernel, because ia64_init_handler
> is a kernel routine, not a module routine.  The sequence goes :-
>=20
> * Kernel boots
>=20
> * ia64_mca_init() -> ia64_sal_set_vectors(), passing the _physical_
>   value of the kernel's gp. This physical address is derived from the
>   region 5 virtual gp by tpa().
>=20
> * Kernel runs.
>   INIT is delivered.  It does not matter what state the machine is in,
>   in kernel, a module or PAL/SAL is irrelevant.
>=20
> * ia64_os_init_dispatch() -> ia64_set_kernel_registers() which converts
>   the physical gp to a region 7 identity mapped virtual gp.
>=20
> * ia64_os_init_dispatch() -> ia64_init_handler().
>=20
> * ia64_init_handler() runs using a region 7 virtual gp.  This is a
>   different virtual address than the original region 5 gp that the
>   kernel booted with, but both the region 5 and region 7 gp values map
>   the same physical pages.
>=20
>=20
  While the content of region 5 and region 7 gp pointed to are the same, th=
e data pointers their self are different.

For the particular sample,
there is a loop, list_for_each_entry(rte, &info->rte, rte_list)
if r1 is set to the identity mapping address in region 7.=20
Where head is pointer to global data structure, so gcc decide to get the &i=
nfo->rte value with the help of gp, then the address become a region 7 valu=
e. However the value in list_entry(head->next) is a region 5 value stored b=
efore.
Then list_for_each_entry() become an endless loop, because pos->member =3D =
head is comparing a region 5 pointer to a region 7 pointer, although they r=
efers to the same physical address, the compare still will not return true.=
...

Note that if we move the code to notify call back function we should not se=
e this problem, because gp in callback function is fetched from function en=
try, kernel fetch the region 5 gp value in function pointer entry with the =
help of region 7 gp,  then in notify callback function we got region 5 gp a=
gain....

However I think this is still an issue,=20
GP is inconsistent to kernel GP at the MCA C codes not referenced by functi=
on pointer.

> >	Kexec kernel used in kdump is usually exactly the same kernel with the
> >host kernel, except they are located in different physical address
> >ranges. The first kernel will never touch the RAM belongs to the crash
> >kernel at run time. The crash kernel will not touch the RAM belongs to
> >the first kernel unless you read it via /proc/vmcore.
>=20
> Which means that the region 7 gp used by MCA/INIT is no good for the
> kexec kernel.  You either need the original region 5 gp or you need to
> adjust r1 by the difference between the physical start of the real
> kernel and the physical start of the kexec kernel.
>=20
  The second kernel is only separated with first kernel in _PHYSICAL_ memor=
y space. They both own the entire virtual address space ... :).=20

  Thanks
Zou Nan hai
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
