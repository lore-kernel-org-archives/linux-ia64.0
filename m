From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 19 Apr 2007 17:15:34 +0000
Subject: RE: [PATCH] kexec/kdump: Use generic elf code on ia64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086C82@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070416074103.GA27981@verge.net.au>
In-Reply-To: <20070416074103.GA27981@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Simon Horman [mailto:horms@verge.net.au]
> Sent: 2007=C4=EA4=D4=C216=C8=D5 16:21
> To: fastboot@lists.osdl.org; linux-ia64@vger.kernel.org
> Cc: Vivek Goyal; Luck, Tony; Zou, Nanhai
> Subject: Re: [PATCH] kexec/kdump: Use generic elf code on ia64
>=20
> Make use of the generic implementation of crash_save_cpu().
>=20
> On ia64 the registers are saved by a kdump-specific function
> ia64_dump_cpu_regs() rather than elf_core_copy_regs() which
> is used by other architectures via crash_save_cpu(). It seems
> that ia64_dump_cpu_regs() and elf_core_copy_regs() are indeed
> quite different
>=20
> In order to facilitate this kdump_elf_core_copy_regs()
> has been created, and it is called by crash_save_cpu().
> By default kdump_elf_core_copy_regs() is just defined to be
> elf_core_copy_regs() and ia64 defines its own implementation,
> which calls ia64_dump_cpu_regs().  The ia64 version also sets
> register 47 in accordance with the code that it replaces.
>=20
> The code appears to work, however as the place where the registers
> are captured has changed natrually some of their values have also changed.
> This makes looking for problems by comparing the new and old output a
> little tricky.
>=20
> Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> ---
> * This patch applies on top of the note size calculation patch
>   that can be found in mm and at
>=20
> http://lists.linux-foundation.org/pipermail/fastboot/2007-April/006792.htm
> l
>=20
>   Porting this patch to not require that one is quite trivial.
>   I can supply a port or a thread containing both patches if it helps.
>=20
> * Update
>   Diff against include/asm-ia64/kexec.h instead of include/asm/kexec.h
>   Ooops!
>=20
>  arch/ia64/kernel/crash.c         |   46
> ++------------------------------------
>  arch/ia64/kernel/machine_kexec.c |    2 -
>  include/asm-ia64/kexec.h              |    7 ++++-
>  include/linux/kexec.h            |    5 ++++
>  kernel/kexec.c                   |    2 -
>  5 files changed, 16 insertions(+), 46 deletions(-)
>=20
> Index: linux-2.6/arch/ia64/kernel/crash.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/arch/ia64/kernel/crash.c	20=
07-04-16
> 16:13:57.000000000 +0900
> +++ linux-2.6/arch/ia64/kernel/crash.c	2007-04-16 16:14:52.000000000
> +0900
> @@ -25,44 +25,11 @@
>  atomic_t kdump_in_progress;
>  static int kdump_on_init =3D 1;
>=20
> -static inline Elf64_Word
> -*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
> -		size_t data_len)
> -{
> -	struct elf_note *note =3D (struct elf_note *)buf;
> -	note->n_namesz =3D strlen(name) + 1;
> -	note->n_descsz =3D data_len;
> -	note->n_type   =3D type;
> -	buf +=3D (sizeof(*note) + 3)/4;
> -	memcpy(buf, name, note->n_namesz);
> -	buf +=3D (note->n_namesz + 3)/4;
> -	memcpy(buf, data, data_len);
> -	buf +=3D (data_len + 3)/4;
> -	return buf;
> -}
> -
> -static void
> -final_note(void *buf)
> -{
> -	memset(buf, 0, sizeof(struct elf_note));
> -}
> -
> -extern void ia64_dump_cpu_regs(void *);
> -
> -static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
> -
>  void
> -crash_save_this_cpu(void)
> +ia64_kexec_elf_core_copy_regs(elf_gregset_t *elfregs, struct pt_regs *re=
gs)
>  {
> -	void *buf;
>  	unsigned long cfm, sof, sol;
> -
> -	int cpu =3D smp_processor_id();
> -	struct elf_prstatus *prstatus =3D &per_cpu(elf_prstatus, cpu);
> -
> -	elf_greg_t *dst =3D (elf_greg_t *)&(prstatus->pr_reg);
> -	memset(prstatus, 0, sizeof(*prstatus));
> -	prstatus->pr_pid =3D current->pid;
> +	elf_greg_t *dst =3D (elf_greg_t *)elfregs;

There was a concern about struct elf_prstatus is so big on IA64 that it bet=
ter not to put it on stack, consider crash happen with a deep stack..., So =
I put the structure into percpu data.

With this patch, it fallbacks to stack.

Thanks
Zou Nan hai

>=20
>  	ia64_dump_cpu_regs(dst);
>  	cfm =3D dst[43];
> @@ -70,13 +37,6 @@
>  	sof =3D cfm & 0x7f;
>  	dst[46] =3D (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
>  			sof - sol);
> -
> -	buf =3D (u64 *) per_cpu_ptr(crash_notes, cpu);
> -	if (!buf)
> -		return;
> -	buf =3D append_elf_note(buf, KEXEC_CORE_NOTE_NAME, NT_PRSTATUS, prstatu=
s,
> -			sizeof(*prstatus));
> -	final_note(buf);
>  }
>=20
>  #ifdef CONFIG_SMP
> @@ -134,7 +94,7 @@
>  	int cpuid;
>  	local_irq_disable();
>  	cpuid =3D smp_processor_id();
> -	crash_save_this_cpu();
> +	crash_save_cpu(NULL, smp_processor_id());
>  	current->thread.ksp =3D (__u64)info->sw - 16;
>  	atomic_inc(&kdump_cpu_frozen);
>  	kdump_status[cpuid] =3D 1;
> Index: linux-2.6/include/asm/kexec.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/include/asm-ia64/kexec.h	20=
07-04-16
> 16:13:57.000000000 +0900
> +++ linux-2.6/include/asm-ia64/kexec.h	2007-04-16 16:14:52.000000000
> +0900
> @@ -19,6 +19,9 @@
>                  flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
>          } while(0)
>=20
> +#define kexec_elf_core_copy_regs(elfregs, regs) \
> +	ia64_kexec_elf_core_copy_regs(elfregs, regs)
> +
>  extern struct kimage *ia64_kimage;
>  extern const unsigned int relocate_new_kernel_size;
>  extern void relocate_new_kernel(unsigned long, unsigned long,
> @@ -32,7 +35,9 @@
>  extern void kdump_smp_send_stop(void);
>  extern void kdump_smp_send_init(void);
>  extern void kexec_disable_iosapic(void);
> -extern void crash_save_this_cpu(void);
> +extern void ia64_dump_cpu_regs(void *);
> +extern void ia64_kexec_elf_core_copy_regs(elf_gregset_t *elfregs,
> +					  struct pt_regs *regs);
>  struct rsvd_region;
>  extern unsigned long kdump_find_rsvd_region(unsigned long size,
>  		struct rsvd_region *rsvd_regions, int n);
> Index: linux-2.6/include/linux/kexec.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/include/linux/kexec.h	2007-=
04-16 16:13:57.000000000
> +0900
> +++ linux-2.6/include/linux/kexec.h	2007-04-16 16:14:52.000000000 +0900
> @@ -128,6 +128,11 @@
>  #define kexec_flush_icache_page(page)
>  #endif
>=20
> +#ifndef kexec_elf_core_copy_regs
> +#define kexec_elf_core_copy_regs(elfregs, regs) \
> +	elf_core_copy_regs(elfregs, regs)
> +#endif
> +
>  #define KEXEC_ON_CRASH  0x00000001
>  #define KEXEC_ARCH_MASK 0xffff0000
>=20
> Index: linux-2.6/kernel/kexec.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/kernel/kexec.c	2007-04-16 1=
6:13:57.000000000 +0900
> +++ linux-2.6/kernel/kexec.c	2007-04-16 16:14:52.000000000 +0900
> @@ -1117,7 +1117,7 @@
>  		return;
>  	memset(&prstatus, 0, sizeof(prstatus));
>  	prstatus.pr_pid =3D current->pid;
> -	elf_core_copy_regs(&prstatus.pr_reg, regs);
> +	kexec_elf_core_copy_regs(&prstatus.pr_reg, regs);
>  	buf =3D append_elf_note(buf, KEXEC_CORE_NOTE_NAME, NT_PRSTATUS,
>  		      	      &prstatus, sizeof(prstatus));
>  	final_note(buf);
> Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/arch/ia64/kernel/machine_ke=
xec.c	2007-04-16
> 16:11:23.000000000 +0900
> +++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2007-04-16
> 16:14:52.000000000 +0900
> @@ -84,7 +84,7 @@
>=20
>  	BUG_ON(!image);
>  	if (image->type =3D KEXEC_TYPE_CRASH) {
> -		crash_save_this_cpu();
> +		crash_save_cpu(NULL, smp_processor_id());
>  		current->thread.ksp =3D (__u64)info->sw - 16;
>  	}
>=20
