From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 02 Feb 2007 03:01:21 +0000
Subject: RE: [PATCH] kexec: Fix CONFIG_SMP=n compilation (ia64)
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BD0@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <aec7e5c30702011838g6e9edd23sc782321aacb07297@mail.gmail.com>
References: <20070201163320.eb4fa2c7.akpm@osdl.org>
In-Reply-To: <20070201163320.eb4fa2c7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Magnus Damm <magnus.damm@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, fastboot@lists.osdl.org, Jay Lan <jlan@sgi.com>

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Magnus Damm
> Sent: 2007=C4=EA2=D4=C22=C8=D5 10:39
> To: Andrew Morton
> Cc: Magnus Damm; linux-kernel@vger.kernel.org; linux-ia64@vger.kernel.org;
> Luck, Tony; fastboot@lists.osdl.org
> Subject: Re: [PATCH] kexec: Fix CONFIG_SMP=3Dn compilation (ia64)
>=20
> On 2/2/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > (added ia64 list)
> > (added ia64 maintainer)
> > (added kexec list)
>=20
> Sorry about that.
>=20
> > On Thu, 01 Feb 2007 22:13:47 +0900
> > Magnus Damm <magnus@valinux.co.jp> wrote:
> >
> > > kexec: Fix CONFIG_SMP=3Dn compilation (ia64)
> > >
> > > This patch makes it possible to compile kexec for ia64 without SMP su=
pport.
> > >
> >
> > Please always include the compiler stderr when fixing build errors or
> > warnings.
>=20
> Ok, will do. With CONFIG_SMP=3Dn and CONFIG_HOTPLUG_CPU=3Dn:
>=20
>   CC      arch/ia64/kernel/machine_kexec.o
> arch/ia64/kernel/machine_kexec.c: In function `machine_shutdown':
> arch/ia64/kernel/machine_kexec.c:77: warning: implicit declaration of
> function `cpu_down'
>   AS      arch/ia64/kernel/relocate_kernel.o
>   CC      arch/ia64/kernel/crash.o
> arch/ia64/kernel/crash.c: In function `kdump_cpu_freeze':
> arch/ia64/kernel/crash.c:139: warning: implicit declaration of
> function `ia64_jump_to_sal'
> arch/ia64/kernel/crash.c:139: error: `sal_boot_rendez_state'
> undeclared (first use in this function)
> arch/ia64/kernel/crash.c:139: error: (Each undeclared identifier is
> reported only once
> arch/ia64/kernel/crash.c:139: error: for each function it appears in.)
> arch/ia64/kernel/crash.c: At top level:
> arch/ia64/kernel/crash.c:84: warning: 'kdump_wait_cpu_freeze' defined
> but not used
> make[1]: *** [arch/ia64/kernel/crash.o] Error 1
> make: *** [arch/ia64/kernel] Error 2
> damm@localhost ~/build/kernel/linux-2.6.20-rc7 $
>=20
> > > --- 0002/arch/ia64/kernel/crash.c
> > > +++ work/arch/ia64/kernel/crash.c     2007-02-01 12:42:38.000000000
> +0900
> > > @@ -79,6 +79,7 @@ crash_save_this_cpu()
> > >       final_note(buf);
> > >  }
> > >
> > > +#ifdef CONFIG_SMP
> > >  static int
> > >  kdump_wait_cpu_freeze(void)
> > >  {
> > > @@ -91,6 +92,7 @@ kdump_wait_cpu_freeze(void)
> > >       }
> > >       return 1;
> > >  }
> > > +#endif
> >
> > I think this is a warning fix?
>=20
> Yes. The file already has some CONFIG_SMP #ifdeffery in it but not
> enough to compile properly.
>=20
> > >  void
> > >  machine_crash_shutdown(struct pt_regs *pt)
> > > @@ -132,11 +134,12 @@ kdump_cpu_freeze(struct unw_frame_info *
> > >       atomic_inc(&kdump_cpu_freezed);
> > >       kdump_status[cpuid] =3D 1;
> > >       mb();
> > > -     if (cpuid =3D 0) {
> > > -             for (;;)
> > > -                     cpu_relax();
> > > -     } else
> > > +#ifdef CONFIG_HOTPLUG_CPU
> > > +     if (cpuid !=3D 0)
> > >               ia64_jump_to_sal(&sal_boot_rendez_state[cpuid]);
> > > +#endif
> > > +     for (;;)
> > > +             cpu_relax();
> > >  }
> >
> > I trust ia64_jump_to_sal doesn't return.
>=20
> So do I. The main problem with the compilation seems to be that
> ia64_jump_to_sal() only exists if CONFIG_HOTPLUG_CPU=3Dy.
> (include/asm-ia64/sal.h, arch/ia64/kernel/head.S)
>=20
 This may cause problem on SN platform.=20
I remember SN requires cpu0 return to SAL rendez loop to do IRQ redirection.
However this needs SGI people to confirm...

Thanks
Zou Nan hai

>=20
> Thanks!
>=20
> / magnus
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
