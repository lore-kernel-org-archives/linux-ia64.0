From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 04 Aug 2006 02:06:20 +0000
Subject: RE: [Fastboot] Ia64 kdump patch
Message-Id: <08B1877B2880CE42811294894F33AD5C053B96@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



> -----Original Message-----
> From: Jay Lan [mailto:jlan@sgi.com]
> Sent: 2006=C4=EA8=D4=C24=C8=D5 9:47
> To: Zou, Nanhai
> Cc: Jay Lan; fastboot@lists.osdl.org; Horms; Linux-IA64; khalid_aziz@hp.c=
om
> Subject: Re: [Fastboot] Ia64 kdump patch
>=20
> Zou Nan hai wrote:
> > On Fri, 2006-07-28 at 05:41, Jay Lan wrote:
> >
> >>Hi,
> >>
> >>I applied the patch to 2.6.18-rc2. However, compilation failed
> >>at machine_shutdown() of arch/ia64/kernel/machine_kexec.c on
> >>an sn2 machine.
> >>
> >>It was easy to figure out irq_descp() is gone and idesc->handle
> >>is replaced with idesc->chip. But this code in machine_shutdown()
> >>caused an error:
> >>
> >>...
> >>if (cpu !=3D smp_processor_id())
> >>cpu_down(cpu);
> >>}
> >>}
> >>#elif defined(CONFIG_SMP)
> >>smp_call_function(kexec_stop_this_cpu, (void *)image->start, 0, 0); <=
=3D> >>#endif
> >>
> >>'image' is undefined in the code. Was it a global? Where was it
> >>declared?
> >>
> >>Thanks,
> >>- jay
> >>
> >
> >   Hi, can you try if it works with CONFIG_HOTPLUG_CPU enabled?
> >   Thanks
> >   Zou Nan hai
>=20
> Sorry i have been pulled away on something else...
> With CONFIG_HOTPLUG_CPU enabled, the problem code would not get
> compiled, thus i was able to create a kernel rpm. Unfortunately
> i failed to boot the sn2 kernel...
>=20
> So i switched to my reference box, an ia64 HP zx box. It booted
> up OK (tiger defconfig). Then i got stuck on a stupid quesiton:
> I was not able to run the 'kexec' command to load the kernel
> specified in the '-p' parameter. What kernel was i supposed
> to specify there? The one i built? Or, a reqular kernel that
> proves to work?
>=20
 It is possible to use the same kernel as the crash dumping kernel,=20
 You should reserve a certain amount of RAM for it by pass a crashkernel=3D=
xxxM@yyyM kernel parameter means " reserved xxxM from yyyM for crash dumpin=
g kernel",=20
Here you should align yyy to 64M.
 Then you will see the "Crash kernel" region in /proc/iomem after first ker=
nel boots.

Thanks
Zou Nan hai
