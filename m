From: Mike Travis <travis@sgi.com>
Date: Wed, 30 Jan 2008 16:02:18 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <47A09F8A.3000309@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be>
In-Reply-To: <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

Geert Uytterhoeven wrote:
> On Wed, 30 Jan 2008, Linux Kernel Mailing List wrote:
>> Gitweb:     http://git.kernel.org/git/?p=3Dlinux/kernel/git/torvalds/lin=
ux-2.6.git;a=3Dcommit;h=DD5af90a7f3d79e04b7eace9a98644dbf2038f4d
>> Commit:     dd5af90a7f3d79e04b7eace9a98644dbf2038f4d
>> Parent:     3212bff370c2f22e4987c6679ba485654cefb178
>> Author:     Mike Travis <travis@sgi.com>
>> AuthorDate: Wed Jan 30 13:33:32 2008 +0100
>> Committer:  Ingo Molnar <mingo@elte.hu>
>> CommitDate: Wed Jan 30 13:33:32 2008 +0100
>>
>>     x86/non-x86: percpu, node ids, apic ids x86.git fixup
>>    =20
>>     Signed-off-by: Ingo Molnar <mingo@elte.hu>
>>     Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>> ---
>>  arch/x86/Kconfig             |    2 +-
>>  include/asm-generic/percpu.h |   12 ++----------
>>  init/main.c                  |    4 ++--
>>  kernel/module.c              |    8 ++++++++
>=20
> This broke powerpc (and presumably ia64 and sparc64) in current linux-2.6=
.git:

I'm generating a "fixup patch" right now...=20

-Mike
>=20
> | init/main.c:376: error: static declaration of 'setup_per_cpu_areas' fol=
lows non-static declaration
> | include2/asm/percpu.h:33: error: previous declaration of 'setup_per_cpu=
_areas' was here
>=20
> as the generic and x86-specific parts were integrated, while the
> powerpc/ia64/sparc64-specific parts are still missing.
>=20
>>  4 files changed, 13 insertions(+), 13 deletions(-)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index f0887d1..8e1b33c 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -97,7 +97,7 @@ config GENERIC_TIME_VSYSCALL
>>  	bool
>>  	default X86_64
>> =20
>> -config ARCH_SETS_UP_PER_CPU_AREA
>> +config HAVE_SETUP_PER_CPU_AREA
>>  	def_bool X86_64
>> =20
>>  config ARCH_SUPPORTS_OPROFILE
>> diff --git a/include/asm-generic/percpu.h b/include/asm-generic/percpu.h
>> index c41b1a7..4b8d31c 100644
>> --- a/include/asm-generic/percpu.h
>> +++ b/include/asm-generic/percpu.h
>> @@ -47,7 +47,7 @@ extern unsigned long __per_cpu_offset[NR_CPUS];
>>  #endif
>> =20
>>  /*
>> - * A percpu variable may point to a discarded reghions. The following a=
re
>> + * A percpu variable may point to a discarded regions. The following are
>>   * established ways to produce a usable pointer from the percpu variable
>>   * offset.
>>   */
>> @@ -59,18 +59,10 @@ extern unsigned long __per_cpu_offset[NR_CPUS];
>>  	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), __my_cpu_offset))
>> =20
>> =20
>> -#ifdef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
>> +#ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
>>  extern void setup_per_cpu_areas(void);
>>  #endif
>> =20
>> -/* A macro to avoid #include hell... */
>> -#define percpu_modcopy(pcpudst, src, size)			\
>> -do {								\
>> -	unsigned int __i;					\
>> -	for_each_possible_cpu(__i)				\
>> -		memcpy((pcpudst)+per_cpu_offset(__i),		\
>> -		       (src), (size));				\
>> -} while (0)
>>  #else /* ! SMP */
>> =20
>>  #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu_var(var)))
>> diff --git a/init/main.c b/init/main.c
>> index 5843fe9..3316dff 100644
>> --- a/init/main.c
>> +++ b/init/main.c
>> @@ -363,7 +363,7 @@ static inline void smp_prepare_cpus(unsigned int max=
cpus) { }
>> =20
>>  #else
>> =20
>> -#ifndef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
>> +#ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
>>  unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
>> =20
>>  EXPORT_SYMBOL(__per_cpu_offset);
>> @@ -384,7 +384,7 @@ static void __init setup_per_cpu_areas(void)
>>  		ptr +=3D size;
>>  	}
>>  }
>> -#endif /* CONFIG_ARCH_SETS_UP_CPU_AREA */
>> +#endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
>> =20
>>  /* Called by boot processor to activate the rest. */
>>  static void __init smp_init(void)
>> diff --git a/kernel/module.c b/kernel/module.c
>> index f6a4e72..bd60278 100644
>> --- a/kernel/module.c
>> +++ b/kernel/module.c
>> @@ -430,6 +430,14 @@ static unsigned int find_pcpusec(Elf_Ehdr *hdr,
>>  	return find_sec(hdr, sechdrs, secstrings, ".data.percpu");
>>  }
>> =20
>> +static void percpu_modcopy(void *pcpudest, const void *from, unsigned l=
ong size)
>> +{
>> +	int cpu;
>> +
>> +	for_each_possible_cpu(cpu)
>> +		memcpy(pcpudest + per_cpu_offset(cpu), from, size);
>> +}
>> +
>>  static int percpu_modinit(void)
>>  {
>>  	pcpu_num_used =3D 2;
>> -
>> To unsubscribe from this list: send the line "unsubscribe git-commits-he=
ad" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>=20
> With kind regards,
>=20
> Geert Uytterhoeven
> Software Architect
>=20
> Sony Network and Software Technology Center Europe
> The Corporate Village =C2=B7 Da Vincilaan 7-D1 =C2=B7 B-1935 Zaventem =C2=
=B7 Belgium
>=20
> Phone:    +32 (0)2 700 8453
> Fax:      +32 (0)2 700 8622
> E-mail:   Geert.Uytterhoeven@sonycom.com
> Internet: http://www.sony-europe.com/
>=20
> Sony Network and Software Technology Center Europe
> A division of Sony Service Centre (Europe) N.V.
> Registered office: Technologielaan 7 =C2=B7 B-1840 Londerzeel =C2=B7 Belg=
ium
> VAT BE 0413.825.160 =C2=B7 RPR Brussels
> Fortis Bank Zaventem =C2=B7 Swift GEBABEBB08A =C2=B7 IBAN BE39001382358619

