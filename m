From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Mon, 28 Aug 2006 01:28:46 +0000
Subject: RE: ia64 kexec: control_page
Message-Id: <08B1877B2880CE42811294894F33AD5C053BD0@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060824073937.GE5280@verge.net.au>
In-Reply-To: <20060824073937.GE5280@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2006=C4=EA8=D4=C224=C8=D5 15:40
> To: Zou, Nanhai
> Cc: fastboot; Linux-IA64; Magnus Damm
> Subject: ia64 kexec: control_page
>=20
> Hi Nanhai,
>=20
> As I've mentioned several times in the past I am working on porting
> kexec to Xen.  And I am once again casting my eye on porting the ia64
> portion.  To this end, I would like to discuss the control_page a
> little.
>=20
> Its currently defined to be 8k + 8k + 4k =3D 20k bytes long, and assembly
> in arch/ia64/kernel/relocate_kernel.S is copied into it.  The resulting
> contents looks a bit like this, as per the most recent patch you posted
> last week.
>=20
>   0x0000: relocate_kernel (code)
>   ...
>   0x0360: memory_stack    (data, 8k)
>   ...
>   0x2360  register_stack  (data, 8k)
>   ...
>   0x4360  kexec_fake_sal_rendez (code)
>   ...
>   0x4640 ia64_dump_cpu_regs (code)
>   ...
>   0x48c0  end
>=20
> The problem that I am facing is that in Xen this region, though
> contiguous in the kernel, is not actually physically contiguous if the
> page size is less than 20k.  As 4k pages don't work for ia64 xen (so I

Hi Horms,
	4k stacks should work in practice.=20
However I defined the 8k stack and backing store sizes according to=20
SAL spec 3.2.4
"Firmware to Operation System Hand-Off state"

The fake_sal_rendz related code is from Aziz for kernel without CONFIG_CPU =
_HOTPLUG enabled,=20
However it is currently not working, still need fix from Aziz.=20

My personal opinion is that we don't need the fake randz code, since they w=
ill not be executed at the time of kdump.=20
While at the time of kexec, we can use the CPU hotplug code to put CPUS bac=
k to SAL rendz state.

Thanks
Zou Nan hai
