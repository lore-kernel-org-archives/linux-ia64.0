From: Mark Anderson <manderso@lsil.com>
Date: Wed, 31 Oct 2001 21:36:59 +0000
Subject: [Linux-ia64] Re: Red Hat 7.1 on Lion
Message-Id: <marc-linux-ia64-105590698805422@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I'm not sure as to documentation, you might want to try the mother
site linux-ia64.org, however the info below should help out:

	1. boot into the EFI shell.
	2. if the mapping does not display (does by default w/EFI
	   v.99 &<) type 'map -r' (-r forces EFI to rescan for
	   devices).
	3. change to the device, or use absolute path for the CDROM
	   (i.e. 'cd fs0:')
	4. a listing should reveal the file elilo.efi (EFI LILO, I
	   believe all versions behave similar, at least this will=20
	   work on ia64 versions from TurboLinux, Mandrake, and=20
	   RedHat)
	5. type 'elilo' or 'elilo.efi' hit enter, and you will see
	   the warm fuzzy 'boot: " prompt.

Mark.


linux-ia64-request@linuxia64.org wrote:
>=20
> Send Linux-IA64 mailing list submissions to
>         linux-ia64@linuxia64.org
>=20
> To subscribe or unsubscribe via the World Wide Web, visit
>         http://lists.linuxia64.org/lists/listinfo/linux-ia64
> or, via email, send a message with subject or body 'help' to
>         linux-ia64-request@linuxia64.org
>=20
> You can reach the person managing the list at
>         linux-ia64-admin@linuxia64.org
>=20
> When replying, please edit your Subject line so it is more specific
> than "Re: Contents of Linux-IA64 digest..."
>=20
> Today's Topics:
>=20
>    1. Red Hat 7.1 on Lion (Gururaj Ananthateerta)
>    2. LION hangs at init 0 (kernel 2.4.13 on top of SuSE 7.2a IA64 Dev.
>        Ed.) (Verkist, Bruno)
>    3. Re: itc sync & clock_* (Jesse Barnes)
>=20
> --__--__--
>=20
> Message: 1
> Date: Tue, 30 Oct 2001 16:48:34 -0800
> From: Gururaj Ananthateerta <gururaj@cup.hp.com>
> Organization: Hewlett Packard
> Cc: "'linux-ia64@linuxia64.org'" <linux-ia64@linuxia64.org>
> Subject: [Linux-ia64] Red Hat 7.1 on Lion
>=20
> Is there any document which explains how to install linux on Lion.
> I am stuck in the EFI shell. I son't know how to install.
> Please help.
> Thanks
> Guru
>=20
> --__--__--
>=20
> Message: 2
> From: "Verkist, Bruno" <Bruno.Verkist@fujitsu-siemens.com>
> To: suse-ia64@suse.com
> Cc: linux-ia64 <linux-ia64@linuxia64.org>
> Date: Wed, 31 Oct 2001 09:35:36 +0100
> Subject: [Linux-ia64] LION hangs at init 0 (kernel 2.4.13 on top of SuSE =
7.2a IA64 Dev.
>  Ed.)
>=20
> Hi all,
>=20
> I have an Intel LION (8GB, 2x733MHz C0, BIOS 100, BMC 26) installed > with
> SuSE 7.2a IA64 Developers Edition (kernel 2.4.4). On top of it I > instal=
led
> kernel 2.4.13 and the IA64 patch linux-2_4_13-ia64-011024_diff .=20
>=20
> Problem: When I reboot the machine with my new 2.4.13 kernel or switch > =
from
> runlevel 1 to 0 the system hangs while executing  > /etc/rc.d/rc0.d/S20ha=
lt.
> The last messages I see on the screen are
>=20
> Sending all processes the TERM signal...
> Sending all processes the KILL signal...
> ...
> T=FDping <Ctrl-C>: blogd: Warning: the ioctl TIOCGDEV is not know by > the
> kernel
>=20
> After that I have to power cycle my LION (and repair my root file > system
> after reboot!).
>=20
> Bruno
>=20
> Bruno Verkist mailto:Bruno.Verkist@fujitsu-siemens.com
> FSC EP PS HE4, Paderborn      Tel. +49 5251 8 15365
>=20
> --__--__--
>=20
> Message: 3
> Date: Wed, 31 Oct 2001 11:41:58 -0800
> From: Jesse Barnes <jbarnes@sgi.com>
> To: David Mosberger <davidm@hpl.hp.com>
> cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] itc sync & clock_*
>=20
> On Mon, 29 Oct 2001, David Mosberger wrote:
>=20
> >       - if there is a driver for a fine-grained machine timer, it can
> >         use it
>=20
> Right, and this should be some sort of generic interface that glibc can
> count on, right?  I've been looking at the multimedia timer spec you
> mentioned for ideas about how to implement it.
>=20
> > Yup.  The driver interface needs to allow direct user-level access to
> > the fine grained timer.  Though I'd say the interface should be able
> > to accommodate hardware that can't map the timer into user space.
>=20
> Ok, I'll keep that in mind.
>=20
> Here's a patch against 2.4.13+ia64 to export the sal platform features to
> a directory in /proc.  Please let me know if it's ok; I'll start working
> on the clock driver if it is.
>=20
> Thanks,
> Jesse
>=20
> diff -Naur --exclude=3D*~ --exclude=3DTAGS linux-2.4.13-ia64/arch/ia64/ke=
rnel/Makefile linux-2.4.13-ia64-salinfo/arch/ia64/kernel/Makefile
> --- linux-2.4.13-ia64/arch/ia64/kernel/Makefile Wed Oct 31 11:25:04 2001
> +++ linux-2.4.13-ia64-salinfo/arch/ia64/kernel/Makefile Wed Oct 31 11:27:=
31 2001
> @@ -15,7 +15,7 @@
>=20
>  obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq=
_ia64.o irq_lsapic.o ivt.o \
>          machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o s=
etup.o \
> -        signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
> +        signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o salinfo.o
>  obj-$(CONFIG_IA64_GENERIC) +=3D iosapic.o
>  obj-$(CONFIG_IA64_DIG) +=3D iosapic.o
>  obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
> diff -Naur --exclude=3D*~ --exclude=3DTAGS linux-2.4.13-ia64/arch/ia64/ke=
rnel/sal.c linux-2.4.13-ia64-salinfo/arch/ia64/kernel/sal.c
> --- linux-2.4.13-ia64/arch/ia64/kernel/sal.c    Wed Oct 31 11:25:04 2001
> +++ linux-2.4.13-ia64-salinfo/arch/ia64/kernel/sal.c    Wed Oct 31 11:29:=
00 2001
> @@ -19,6 +19,7 @@
>  #include <asm/pal.h>
>=20
>  spinlock_t sal_lock =3D SPIN_LOCK_UNLOCKED;
> +unsigned long sal_platform_features =3D 0;
>=20
>  static struct {
>         void *addr;     /* function entry point */
> @@ -154,11 +155,13 @@
>                               struct ia64_sal_desc_platform_feature *pf =
=3D (void *) p;
>                               printk("SAL: Platform features ");
>=20
> -                             if (pf->feature_mask & (1 << 0))
> +                             if (pf->feature_mask & IA64_SAL_PLATFORM_FE=
ATURE_BUS_LOCK) {
>                                       printk("BusLock ");
> -
> -                             if (pf->feature_mask & (1 << 1)) {
> +                                     sal_platform_features |=3D IA64_SAL=
_PLATFORM_FEATURE_BUS_LOCK;
> +                             }
> +                             if (pf->feature_mask & IA64_SAL_PLATFORM_FE=
ATURE_IRQ_REDIR_HINT) {
>                                       printk("IRQ_Redirection ");
> +                                     sal_platform_features |=3D IA64_SAL=
_PLATFORM_FEATURE_IRQ_REDIR_HINT;
>  #ifdef CONFIG_SMP
>                                       if (no_int_routing)
>                                               smp_int_redirect &=3D ~SMP_=
IRQ_REDIRECTION;
> @@ -166,14 +169,19 @@
>                                               smp_int_redirect |=3D SMP_I=
RQ_REDIRECTION;
>  #endif
>                               }
> -                             if (pf->feature_mask & (1 << 2)) {
> +                             if (pf->feature_mask & IA64_SAL_PLATFORM_FE=
ATURE_IPI_REDIR_HINT) {
>                                       printk("IPI_Redirection ");
> +                                     sal_platform_features |=3D IA64_SAL=
_PLATFORM_FEATURE_IPI_REDIR_HINT;
>  #ifdef CONFIG_SMP
>                                       if (no_int_routing)
>                                               smp_int_redirect &=3D ~SMP_=
IPI_REDIRECTION;
>                                       else
>                                               smp_int_redirect |=3D SMP_I=
PI_REDIRECTION;
>  #endif
> +                             }
> +                             if (pf->feature_mask & IA64_SAL_PLATFORM_FE=
ATURE_ITC_MAY_DRIFT) {
> +                                     printk("ITC_may_drift ");
> +                                     sal_platform_features |=3D IA64_SAL=
_PLATFORM_FEATURE_ITC_MAY_DRIFT;
>                               }
>                               printk("\n");
>                               break;
> diff -Naur --exclude=3D*~ --exclude=3DTAGS linux-2.4.13-ia64/arch/ia64/ke=
rnel/salinfo.c linux-2.4.13-ia64-salinfo/arch/ia64/kernel/salinfo.c
> --- linux-2.4.13-ia64/arch/ia64/kernel/salinfo.c        Wed Dec 31 16:00:=
00 1969
> +++ linux-2.4.13-ia64-salinfo/arch/ia64/kernel/salinfo.c        Wed Oct 3=
1 11:36:35 2001
> @@ -0,0 +1,104 @@
> +/*
> + * salinfo.c
> + *
> + * Creates entries in /proc/sal for various system features.
> + *
> + * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
> + *
> + * 10/30/2001  jbarnes@sgi.com         copied much of Stephane's palinfo
> + *                                     code to create this file
> + */
> +
> +#include <linux/types.h>
> +#include <linux/proc_fs.h>
> +#include <linux/module.h>
> +
> +#include <asm/sal.h>
> +
> +MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
> +MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
> +
> +int salinfo_read(char *page, char **start, off_t off, int count, int *eo=
f, void *data);
> +
> +typedef struct {
> +       const char              *name;          /* name of the proc entry=
 */
> +       unsigned long           feature;        /* feature bit */
> +       struct proc_dir_entry   *entry;         /* registered entry (remo=
val) */
> +} salinfo_entry_t;
> +
> +/*
> + * List {name,feature} pairs for every entry in /proc/sal/<feature>
> + * that this module exports
> + */
> +static salinfo_entry_t salinfo_entries[]=3D{
> +       { "bus_lock",           IA64_SAL_PLATFORM_FEATURE_BUS_LOCK, },
> +       { "irq_redirection",    IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT,=
 },
> +       { "ipi_redirection",    IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT,=
 },
> +       { "itc_may_drift",      IA64_SAL_PLATFORM_FEATURE_ITC_MAY_DRIFT, =
},
> +};
> +
> +#define NR_SALINFO_ENTRIES (sizeof(salinfo_entries)/sizeof(salinfo_entry=
_t))
> +
> +/*
> + * One for each feature and one more for the directory entry...
> + */
> +static struct proc_dir_entry *salinfo_proc_entries[NR_SALINFO_ENTRIES + =
1];
> +
> +static int __init
> +salinfo_init(void)
> +{
> +       struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
> +       struct proc_dir_entry **sdir =3D salinfo_proc_entries; /* keeps t=
rack of every entry */
> +       int i;
> +
> +       salinfo_dir =3D proc_mkdir("sal", NULL);
> +
> +       for (i=3D0; i < NR_SALINFO_ENTRIES; i++) {
> +               /* pass the feature bit in question as misc data */
> +               *sdir++ =3D create_proc_read_entry (salinfo_entries[i].na=
me, 0, salinfo_dir,
> +                                                 salinfo_read, (void *)s=
alinfo_entries[i].feature);
> +       }
> +       *sdir++ =3D salinfo_dir;
> +
> +       return 0;
> +}
> +
> +static void __exit
> +salinfo_exit(void)
> +{
> +       int i =3D 0;
> +
> +       for (i =3D 0; i < NR_SALINFO_ENTRIES ; i++) {
> +               if (salinfo_proc_entries[i])
> +                       remove_proc_entry (salinfo_proc_entries[i]->name,=
 NULL);
> +       }
> +}
> +
> +/*
> + * 'data' contains an integer that corresponds to the feature we're
> + * testing
> + */
> +int
> +salinfo_read(char *page, char **start, off_t off, int count, int *eof, v=
oid *data)
> +{
> +       int len =3D 0;
> +
> +       MOD_INC_USE_COUNT;
> +
> +       len =3D sprintf(page, (sal_platform_features & (unsigned long)dat=
a) ? "1" : "0");
> +
> +       if (len <=3D off+count) *eof =3D 1;
> +
> +       *start =3D page + off;
> +       len   -=3D off;
> +
> +       if (len>count) len =3D count;
> +       if (len<0) len =3D 0;
> +
> +       MOD_DEC_USE_COUNT;
> +
> +       return len;
> +}
> +
> +module_init(salinfo_init);
> +module_exit(salinfo_exit);
> diff -Naur --exclude=3D*~ --exclude=3DTAGS linux-2.4.13-ia64/include/asm-=
ia64/sal.h linux-2.4.13-ia64-salinfo/include/asm-ia64/sal.h
> --- linux-2.4.13-ia64/include/asm-ia64/sal.h    Wed Oct 31 11:25:05 2001
> +++ linux-2.4.13-ia64-salinfo/include/asm-ia64/sal.h    Wed Oct 31 11:32:=
32 2001
> @@ -149,6 +149,7 @@
>  #define IA64_SAL_PLATFORM_FEATURE_BUS_LOCK             (1 << 0)
>  #define IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT       (1 << 1)
>  #define IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT       (1 << 2)
> +#define IA64_SAL_PLATFORM_FEATURE_ITC_MAY_DRIFT        (1 << 3)
>=20
>  typedef struct ia64_sal_desc_platform_feature {
>         u8 type;
> @@ -775,5 +776,7 @@
>                 *scratch_buf_size_needed =3D isrv.v1;
>         return isrv.status;
>  }
> +
> +extern unsigned long sal_platform_features;
>=20
>  #endif /* _ASM_IA64_PAL_H */
>=20
> --__--__--
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20
> End of Linux-IA64 Digest

--=20
Mark Anderson
Software Test
Storage Standard Products
LSI Logic=20
Phone:    719-533-7507
Fax:      719-533-7430
E-mail:   mark.anderson@lsil.com
Mailstop: AL-101

