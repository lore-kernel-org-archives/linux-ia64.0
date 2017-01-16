From: Borislav Petkov <bp@alien8.de>
Date: Mon, 16 Jan 2017 14:46:53 +0000
Subject: Re: [PATCH v6 01/14] generic-sections: add section core helpers
Message-Id: <20170116144653.zyfnm5lzwlh5xdfg@pd.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023811.21246-1-mcgrof@kernel.org>
 <20170109145833.11502-1-mcgrof@kernel.org>
 <20170109145833.11502-2-mcgrof@kernel.org>
In-Reply-To: <20170109145833.11502-2-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org

On Mon, Jan 09, 2017 at 06:58:19AM -0800, Luis R. Rodriguez wrote:
> Linux makes extensive use of custom ELF header sections,
> documentation for these are well scatterred. Unify this

			  is

> documentation in a central place and provide helpers to
> build custom Linux sections.

This patch contains at least three logical changes and needs splitting:

* unify documentation
* adding helpers
* MAINTAINERS addition

Documentation and MAINTAINERS changes should go last in the patchset.

Accordingly, the huuge commit message below should be spread around
those three patches.

>=20
> This also generalizes sections code to enable avoiding
> modifying the linker scripts when we want to add new
> custom Linux sections. In order to make this generally
> useful we need to ensure all architectures can make use of
> core section helpers but that they can also override should
> this be needed. Instead of relying on section.h this adds
> a sections-core.h since this will be targetted to be safe
> to be used on asm code, linker scripts and C code.
>=20
> v5:
>=20
> o Huge documentation revamp based on a careful review of the ELF
>   specifications. Includes documentation now also about usage of
>   two dots (..) when prefixing ELF program specific sections.
>=20
> o Replace macros for sections names in favor of just using
>   the section names explicitly in the linker script. This is
>   perhaps more work to grep but this is what folks seem to
>   currently prefer.
>=20
> o Fix .text and .rodata documentation to explain memory protection
>   strategies which architectures can embrace upon initialization
>   (documents CONFIG_DEBUG_RODATA and mark_rodata_ro())
>=20
> o Skip the 'Linux section ordering' documentation section, we'll instead
>   add this on subsequent patch which will expand on it considerably
>=20
> o Dropped tree on MAINTAINERS -- as per discussions with Arnd, hpa and
>   Josh, its easier to just let changes for sections go in through the
>   respective tree that needs the changes.
>=20
> o Fix typos on documentation
>=20
> o Dropped SECTION_ALL(), __SECTION_CORE(), SECTION_CORE_ALL() macros
>   since we are favoring using explicit section names. These are
>   useless if we are being explicit.
>=20
> o Drop LINUX_SECTION_SIZE(), LINUX_SECTION_EMPTY() in favor of having
>   section ranges and linker tables define their own, to avoid confusion
>   and make code more readable.
>=20
> o Add __define_initcall() documentation and a small section describing
>   our current initcall levels. This should help also clarify what was
>   meant about keeping backward compatiblity.
>=20
> v4:
>=20
> o Port to shiny new sphinx documentation format

This looks like a 4th patch ontop of the unifying documentation one.

>=20
> o fix a unicore32 build, turns out this actually fixes unicore32
>   defconfig builds which were failing for a long while. unicore32
>   does not seem to grok well the type passed on a section declaration,
>   this ignores it.
>=20
> o Use VMLINUX_SYMBOL() in more user symbols (extern C code), not doing
>   this was causing final linker issues with blackfin -- this is
>   a CONFIG_HAVE_UNDERSCORE_SYMBOL_PREFIX=3Dy architecture. The other one
>   being metatag. metatag is not supported on 0-day so I cannot confirm
>   compilation there.

...

> +++ b/Documentation/sections/background.rst
> @@ -0,0 +1,105 @@
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +ELF section background
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +About
> +=3D=3D> +
> +The purpose of this chapter is to help those not familiar with ELF to br=
ush up
> +the latest ELF specifications in order to help understand how Linux uses=
 and
> +defines its own ELF sections.
> +
> +Standardized ELF
> +=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +The first publication documenting ELF was UNIX System Laboratories' (USL)
> +*System V Release 4 Application Binary Interface* (`SRV4 ABI`_) specific=
ation.
> +Originally ELF was only a small part of the SRV4 ABI, with time however =
new
> +specifications only put focus on ELF, such was the case of the *TIS Port=
able
> +Formats Specification version 1.2* (`TIS 1.2`_). As of TIS 1.2, ELF was
> +supplemented with processor specific ELF addendums, available on the *Li=
nux
> +Foundation referenced specification page* (`LF ref page`_). The latest E=
LF
> +specification is the *System V Application Binary Interface - DRAFT - 24=
 April
> +2001* (`gabi4`_).
> +
> +.. _SRV4 ABI: http://www.sco.com/developers/devspecs/gabi41.pdf
> +.. _TIS 1.2: https://refspecs.linuxbase.org/elf/elf.pdf
> +.. _LF ref page: https://refspecs.linuxbase.org/
> +.. _gabi4: https://refspecs.linuxbase.org/elf/gabi4+/contents.html
> +

A pointer to the wikipedia page would suffice instead of us repeating
ELF history here.

> +ELF views on Linux
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +There are two views which can be used for inspecting data in an ELF file=
, a
> +Linking view, and an Execution view. A Section Header Table enables one =
to
> +describe an object using the Linking view while a Program Header Table e=
nables
> +one to describe an object using the Execution view. The views are not mu=
tually
> +exclusive. For intance, vmlinux can be viewed under both views, ``readel=
f -S

s/intance/instance/

> +vmlinux`` for the Linking view, and ``readelf -l vmlinux`` for the Execu=
tion
> +view.  In Linux only the vmlinux file will have an Execution view, even =
modules
> +lack an Execution view given that vmlinux is the only file that describe=
s how
> +the the kernel runs from the start.  All other Linux kernel object files=
 have

s/the //

> +an available Linking view.

s/n available// - "have a Linking view" is fine.

> +
> +Under the Linking view, the Section Header Table describes all available
> +sections. The Section Header Table is an array of ELF section header data
> +structures. If on a 32-bit system this is ``struct elf32_shd``, if on a =
64-bit
> +this is ``struct elf64_shdr``.

"If on ... if on" doesn't work as a sentence.

> Sections are only visible on object files that

s/on/in/

> +have a Linking view, since all Linux kernel files have Linking view, all=
 kernel
> +objects have ELF sections.

Btw, that last sentence is kinda funny and not really needed. Or do you
wanna say that everything-code is in a section?

> +
> +Limitations on ELF sections

ELF sections limitations

> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> +
> +We provide a summary on the limitations of ELF sections.

Kill that sentence.

> Refer to the public
> +ELF specifications for details. Note that 64-bit limitations may depend
> +on processor specific section attributes to be used, refer to your proce=
sssor

"processsor" - the 's' button stuck? :-)

> +specification if unsure.

Better yet, kill that whole paragraph.

> +
> +Its worth ellaborating on the limitations on the name of an ELF section:

"elaborating"

> +ELF section names are stored as strings as per the ELF specification, and
> +as can be expected, these don't have explicit limitations. The implicit
> +limitation then depends on the size of an ELF object file and ELF sectio=
n.
> +
> +If using really large kernels or objects with large amounts of sections =
one
> +would still need to be sure that ELF loader in charge of loading the Lin=
ux
> +kernel is properly updated to handle coping with the latest ELF extensio=
ns.
> +
> +   .. flat-table:: Limitations on ELF Sections
> +
> +      * - Section attribute
> +        - 32-bit
> +        - 64-bit
> +
> +      * - ELF section name
> +        - Size of an ELF section
> +        - Size of an ELF section
> +
> +      * - Size of an ELF section
> +        - 4 GiB
> +        - 16 EiB
> +
> +      * - Max number of sections in an object file
> +        - 4 GiEntries (4294967296)
> +        - 16 EiEntries (18446744073709551616)
> +
> +Program specific ELF sections

Program-specific

> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> +
> +The ELF specification allows for a section type to be specified as
> +*Program specific section*, defined as ``SHT_PROGBITS``. This sections t=
ype

								 section

> +enables programs to customize sections for their own use. In assembly th=
is
									^
									is

> +specified ``@progbits`` on most architectures, on ARM this is ``%progbit=
s``.
	     ^		  ^

	     with the	  flag				s/this is/it is called/

> +
> +``SHT_PROGBITS`` is used by Linux for defining and using Linux ELF secti=
ons.
> +
> +Special ELF Sections
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +The ELF specification defines *Special ELF Sections* on chapter 4 (`gabi4
> +ch4`_). These are defined as sections which hold program and control
> +information. Of these sections, a few have the section type as
> +``SHT_PROGBITS``. This enables Linux to *further customize* use of the s=
ection
> +beyond what the ELF specification suggests.
> +
> +.. _gabi4 ch4: https://refspecs.linuxbase.org/elf/gabi4+/ch4.sheader.htm=
l#special_sections
> diff --git a/Documentation/sections/conf.py b/Documentation/sections/conf=
.py
> new file mode 100644
> index 000000000000..faa1c57595e1
> --- /dev/null
> +++ b/Documentation/sections/conf.py
> @@ -0,0 +1,4 @@
> +# -*- coding: utf-8; mode: python -*-
> +
> +project =3D 'Linux Kernel ELF sections'
> +html_search_language =3D 'en'
> diff --git a/Documentation/sections/index.rst b/Documentation/sections/in=
dex.rst
> new file mode 100644
> index 000000000000..f37511ef05e7
> --- /dev/null
> +++ b/Documentation/sections/index.rst
> @@ -0,0 +1,17 @@
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> +Linux Kernel ELF sections
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> +
> +This book documents the different ELF sections used on the Linux kernel.

							in

> +We start off by providing references to how ELF was standardized, refere=
nces
> +to the standards on ELF sections, review limitations of ELF sections, and
> +finally how Linux uses ELF sections in the Linux kernel. Certain importa=
nt
> +Linux ELF sections are documented carefully: we describe the goal of the
> +ELF section, and address concurrency considerations when applicable. A f=
ew
> +common a set of Linux helpers for ELF sections are also documented.

s/few common a //

> +
> +.. toctree::
> +   :maxdepth: 4
> +
> +   background
> +   section-core

...

> diff --git a/arch/unicore32/include/asm/section-core.h b/arch/unicore32/i=
nclude/asm/section-core.h
> new file mode 100644
> index 000000000000..0b9c68429a1a
> --- /dev/null
> +++ b/arch/unicore32/include/asm/section-core.h
> @@ -0,0 +1,19 @@
> +#ifndef __UNICORE_SECTION_CORE_ASM_H__
> +#define __UNICORE_SECTION_CORE_ASM_H__
> +/*
> + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> + *
> + * This program is free software; you can redistribute it and/or modify =
it
> + * under the terms of copyleft-next (version 0.3.1 or later) as published
> + * at http://copyleft-next.org/.

Isn't all kernel code GPLv2?

> + */
> +
> +/* Unicore32 has known to not work properly with the type set, so ignore=
 it */
> +
> +#define __set_section_core_type(___section, ___core, ___name,		\
> +				___level, ___flags, ___type)		\
> +	.section ___section..___core.___name.___level, ___flags
> +
> +#include <asm-generic/section-core.h>
> +
> +#endif /* __UNICORE_SECTION_CORE_ASM_H__ */
> diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
> index 2b892e2313a9..af975f21eeee 100644
> --- a/arch/x86/include/asm/Kbuild
> +++ b/arch/x86/include/asm/Kbuild
> @@ -12,3 +12,4 @@ generic-y +=3D dma-contiguous.h
>  generic-y +=3D early_ioremap.h
>  generic-y +=3D mcs_spinlock.h
>  generic-y +=3D mm-arch-hooks.h
> +generic-y +=3D section-core.h
> diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbu=
ild
> index b7fbaa56b51a..7879c31e66a7 100644
> --- a/arch/xtensa/include/asm/Kbuild
> +++ b/arch/xtensa/include/asm/Kbuild
> @@ -32,3 +32,4 @@ generic-y +=3D topology.h
>  generic-y +=3D trace_clock.h
>  generic-y +=3D word-at-a-time.h
>  generic-y +=3D xor.h
> +generic-y +=3D section-core.h
> diff --git a/include/asm-generic/section-core.h b/include/asm-generic/sec=
tion-core.h
> new file mode 100644
> index 000000000000..bb16befc4251
> --- /dev/null
> +++ b/include/asm-generic/section-core.h
> @@ -0,0 +1,307 @@
> +#ifndef _ASM_GENERIC_SECTION_CORE_H_
> +#define _ASM_GENERIC_SECTION_CORE_H_
> +/*
> + * Linux section core definitions
> + *
> + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> + *
> + * This program is free software; you can redistribute it and/or modify =
it
> + * under the terms of copyleft-next (version 0.3.1 or later) as published
> + * at http://copyleft-next.org/.

Ditto.

> + */
> +
> +/**
> + * DOC: Linux ELF program specific sections
> + *
> + * Linux makes extensive use of ``SHT_PROGBITS`` to both extend use and =
definition
							     ^^^^^^^^^^^^^^^^^^^^^^^^

							     needs rewording

> of *Special ELF Sections* (`gabi4 ch4`_) and to define its own
> + * sections. This chaper is dedicated to documenting Linux program speci=
fic

"chapter"

Please spellcheck the whole patchset before next submission.

> + * sections and helpers available to make use of these easier to impleme=
nt and
> + * use.

Huh, come again? This sentence is funny.

> + *
> + * .. _gabi4 ch4: https://refspecs.linuxbase.org/elf/gabi4+/ch4.sheader.=
html#special_sections
> + */
> +
> +/**
> + * DOC: Linux linker script
> + *
> + * Linux uses a custom linker script to build the vmlinux binary, it use=
s it to
> + * strategically place and define Linux ELF sections.  Each architecture=
 needs
> + * to implement its own linker script, it is expected to reside in

			      ... script which is expected ...

> + * ``arch/$(ARCH)/kernel/vmlinux.lds.S``.  Architecture Linux linker scr=
ipts in
> + * turn include and use definitions from ``include/asm-generic/vmlinux.l=
ds.h``,
> + * as well as some helpers documented in this chapter.
> + *
> + * In assembly it is common practice to use dots (``.``) in labels to av=
oid
> + * clashes with C symbols. Similarly, a dot (``.``) can be part of a sec=
tion
> + * name but not a C symbol. Historically then, two dots are used (``..``)
> + * have been used in linker scripts when adding program specific sections

are used .. have been used?

> + * when there are concerns to avoid clashes with compiler generated sect=
ions.

This last sentence needs simplifying.

> + */
> +
> +/**
> + * DOC: Memory protection
> + *
> + * Linux allows architectures which support memory protection features to
> + * take advantage of them by letting architectures define and enable
> + * ``CONFIG_DEBUG_RODATA`` and implement a mark_rodata_ro() call.

Simplify: "Architectures with memory protection features can define and
enable CONFIG_DEBUG_RODATA... "

> + * mark_rodata_ro() can be used for instance to mark specific sections as
				  , for instance,=20


> + * read-only or non-executable.
> + *
> + * Linux typically follows a convention to have the .rodata ELF section =
follow
> + * after the .text ELF section, it does this to help architectures which
				 . It does this...

> + * support memory protection to mark both .text and .rodata as read-only=
 in
> + * one shot.
> + *
> + * For more details refer to mark_rodata_ro().
> + */
> +
> +/**
> + * DOC: .rodata
> + *
> + * ELF section used for data which must be protected from write access.
> + */
> +
> +/**
> + * DOC: .text
> + *
> + * ELF section name used for code (functions) used during regular
> + * kernel run time.
> + */
> +
> +/**
> + * DOC: .data
> + *
> + * ELF section used for read-write data.
> + */
> +
> +/**
> + * DOC: Linux init sections
> + *
> + * These sections are used for code and data structures used during boot=
 or
> + * module initialization. On architectures that support it (x86, x86_64)=
, all
> + * this code is freed up by the kernel right before the fist userspace i=
nit
> + * process is called when built-in to the kernel, and if modular it is f=
reed
> + * after module initialization. Since the code is freed so early, in the=
ory
> + * there should be no races against freeing this code with other CPUs. I=
nit
> + * section code and data structures should never be exported with
> + * EXPORT_SYMBOL*() as the code will quickly become unavailable to the k=
ernel
> + * after bootup.
> + */
> +
> +/**
> + * DOC: .init.text
> + *
> + * ELF section for code (functions) used only during boot or driver
> + * initialization.
> + *
> + */
> +
> +/**
> + * DOC: .init.data
> + *
> + * ELF section used for data structures used only during boot or driver
> + * initialization.
> + */
> +
> +/**
> + * DOC: .init.rodata
> + *
> + * ELF section used for read-only code (functions) used only during boot
> + * or driver initialization.
> + */
> +
> +/**
> + * DOC: .initcall
> + *
> + * ELF section used for subsystem init calls. There are init levels
> + * representing different functionality in the kernel. For more details
> + * refer to __define_initcall().
> + */
> +
> +/**
> + * DOC: Linux exit sections
> + *
> + * These sections are used to declare a functions and data structures wh=
ich

s/a //

> + * are only required on exit, the function or data structure will be dro=
pped
> + * if the code declaring this section is not compiled as a module on
> + * architectures that support this (x86, x86_64). There is no special ca=
se
> + * handling for this code when built-in to the kernel.
> + */
> +
> +/**
> + * DOC: .exit.text
> + *
> + * ELF section used to for code (functions) used only during module unlo=
ad.
> + */
> +
> +/**
> + * DOC: .exit.data
> + *
> + * ELF section used to for data structures used only during module
> + * unload.
> + */
> +
> +/**
> + * DOC: .exitcall.exit
> + *
> + * ELF section used for exit routines, order is important and maintained=
 by
> + * link order.
> + */
> +
> +/**
> + * DOC: Linux references to init sections
> + *
> + * These sections are used to teach modpost to not warn about possible
> + * misuses of init section code from other sections. If you use this
> + * your use case should document why you are certain such use of init
> + * sectioned code is valid. For more details refer to ``include/linux/in=
it.h``
> + * ``__ref``, ``__refdata``, and ``__refconst`` documentation.
> + */
> +
> +/**
> + * DOC: .ref.text
> + *
> + * ELF section used to annotate code (functions) which has been vetteed =
as

vetted?

> + * valid for its reference or use of other code (functions) or data stru=
ctures
> + * which are part of the init sections.
> + */
> +
> +/**
> + * DOC: .ref.data
> + *
> + * ELF section used for data structures which have been vetteed for its

ditto.

> + * reference or use of other code (functions) or data structures part of=
 the
> + * init sections.
> + */
> +
> +/**
> + * DOC: .ref.rodata
> + *
> + * ELF section used to annotate const code (functions) const data struct=
ures
> + * which has been vetteed for its reference or use of other code (functi=
ons)

ditto.

> + * or data structures part of the init sections.
> + */
> +
> +/* Can be used on foo.S for instance */

What does that comment mean?

> +#ifndef __set_section_core_type
> +# define __set_section_core_type(___section, ___core, ___name,		\
> +				 ___level, ___flags, ___type)		\
> +	.section ___section..___core.___name.___level, ___flags, ___type

Are you sure we need 4 levels of hierarchy?

If so, we should document what all those section, core, name and level
mean and how the whole sections hierarchy is supposed to look like.

> +#endif
> +
> +#ifndef __set_section_core
> +# define __set_section_core(___section, ___core, ___name, ___level, ___f=
lags) \
> +	.section ___section..___core.___name.___level, ___flags
> +#endif
> +
> +#ifndef __push_section_core
> +# define __push_section_core(__section, __core, __name, __level, __flags=
) \
> +	.pushsection __section..__core.__name.__level, __flags
> +#endif
> +
> +#ifdef __KERNEL__
> +#include <linux/stringify.h>
> +#endif
> +
> +#if defined(__ASSEMBLER__) || defined(__ASSEMBLY__)
> +
> +# ifndef LINKER_SCRIPT
> +
> +#  ifndef push_section_core
> +#   define push_section_core(__section, __core, __name, __level, __flags=
) \
> +	 __push_section_core(__section, __core, __name,			  \
> +			     __level, __stringify(__flags))
> +#  endif
> +
> +#  ifndef set_section_core
> +#   define set_section_core(__section, __core, __name,			\
> +			    __level, __flags)				\
> +	__set_section_core(__section, __core, __name,			\
> +			   __level, __stringify(__flags))
> +#  endif
> +
> +#  ifndef set_section_core_type
> +#   define set_section_core_type(__section, __core, __name,		\
> +				 __level, __flags, __type)		\
> +	__set_section_core_type(__section, __core, __name, __level,	\
> +				__stringify(__flags), __type)
> +#  endif
> +
> +# endif /* LINKER_SCRIPT */
> +#else /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
> +
> +/*
> + * As per gcc's documentation a common asm separator is a new line follo=
wed
> + * by tab [0], it however seems possible to also just use a newline as i=
ts

		. It, however, seems ...

> + * the most commonly empirically observed semantic and folks seem to agr=
ee
> + * this even works on S390. In case your architecture disagrees you may
> + * override this and define your own and keep the rest of the macros.
> + *
> + * [0] https://gcc.gnu.org/onlinedocs/gcc/Basic-Asm.html#Basic-Asm
> + */
> +# ifndef ASM_CMD_SEP
> +#  define ASM_CMD_SEP	"\n"
> +# endif
> +
> +# ifndef set_section_core
> +#  define set_section_core(__section, __core, __name, __level, __flags)	\
> +	__stringify(__set_section_core_type(__section, __core, __name,	\
> +					    __level, __stringify(__flags))) \
> +	ASM_CMD_SEP
> +# endif
> +
> +/*
> + * Some architectures (arm, and avr32 are two examples on kprobes) seem
> + * currently explicitly specify the type [0] -- this can be any of the
> + * optional constants on ELF:
> + *
> + * @progbits - section contains data
> + * @nobits - section does not contain data (i.e., section only occupies =
space)
> + * @note - section contains data which is used by things other than the =
program
> + * @init_array - section contains an array of pointers to init functions
> + * @fini_array - section contains an array of pointers to finish functio=
ns
> + * @preinit_array - section contains an array of pointers to pre-init fu=
nctions
> + *
> + * ARM requires % instead of @.
> + *
> + * At least as per nasm (x86/x86_64 only), in the absence of qualifiers =
the
> + * defaults are as follows:
> + *
> + * section .text    progbits  alloc   exec    nowrite  align=16
> + * section .rodata  progbits  alloc   noexec  nowrite  align=3D4
> + * section .lrodata progbits  alloc   noexec  nowrite  align=3D4
> + * section .data    progbits  alloc   noexec  write    align=3D4
> + * section .ldata   progbits  alloc   noexec  write    align=3D4
> + * section .bss     nobits    alloc   noexec  write    align=3D4
> + * section .lbss    nobits    alloc   noexec  write    align=3D4
> + * section .tdata   progbits  alloc   noexec  write    align=3D4    tls
> + * section .tbss    nobits    alloc   noexec  write    align=3D4    tls
> + * section .comment progbits  noalloc noexec  nowrite  align=3D1
> + * section other    progbits  alloc   noexec  nowrite  align=3D1
> + *
> + * gas should have sensible defaults for architectures...
> + *
> + * [0] http://www.nasm.us/doc/nasmdoc7.html
> + */
> +# ifndef set_section_core_type
> +#  define set_section_core_type(__section, __core, __name, __level,	\
> +				__flags, __type)			\
> +	__stringify(__set_section_core_type(__section, __core,		\
> +					    __name, __level,		\
> +					    __stringify(__flags),	\
> +					    __type))			\
> +	ASM_CMD_SEP
> +# endif
> +
> +# ifndef push_section_core
> +#  define push_section_core(__section, __core, __name,			\
> +			    __level, __flags)				\
> +	__stringify(__push_section_core(__section, __core,		\
> +					__name,	__level,		\
> +					__stringify(__flags)))		\
> +	ASM_CMD_SEP
> +# endif
> +
> +#endif /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
> +#endif /* _ASM_GENERIC_SECTION_CORE_H_ */
> diff --git a/include/asm-generic/sections.h b/include/asm-generic/section=
s.h
> index 4df64a1fc09e..b145ae8d9cbe 100644
> --- a/include/asm-generic/sections.h
> +++ b/include/asm-generic/sections.h
> @@ -1,6 +1,8 @@
>  #ifndef _ASM_GENERIC_SECTIONS_H_
>  #define _ASM_GENERIC_SECTIONS_H_
> =20
> +#include <asm/section-core.h>
> +
>  /* References to section boundaries */
> =20
>  #include <linux/compiler.h>
> diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmli=
nux.lds.h
> index 0968d13b3885..483f60c451f9 100644
> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
> @@ -55,6 +55,7 @@
>  #endif
> =20
>  #include <linux/export.h>
> +#include <asm/section-core.h>
> =20
>  /* Align . to a 8 byte boundary equals to maximum function alignment. */
>  #define ALIGN_FUNCTION()  . =3D ALIGN(8)
> diff --git a/include/linux/init.h b/include/linux/init.h
> index 885c3e6d0f9d..116e3262332a 100644
> --- a/include/linux/init.h
> +++ b/include/linux/init.h
> @@ -130,6 +130,24 @@ int __init init_rootfs(void);
>  extern bool rodata_enabled;
>  #endif
>  #ifdef CONFIG_DEBUG_RODATA
> +/**
> + * mark_rodata_ro - implemement memory protection for ELF sections
> + *
> + * Architectures which support memory protection define a kernel configu=
ration
> + * entry for CONFIG_DEBUG_RODATA,

That's just too many words for nothing. You can just as well say:

"Architectures which support memory protection enable CONFIG_DEBUG_RODATA a=
nd
implement mark_rodata_ro()."

> enable it in and implement mark_rodata_ro().
> + * mark_rodata_ro() should strive to adjust the .rodata and .text ELF se=
ctions
> + * with read-only memory protection to prevent modifications of these se=
ctions

"mark_rodata_ro() marks .rodata and .text section read-only..."

Simple.

> + * after bootup. It can also try to use memory protection to prevent exe=
cution
> + * on the .rodata ELF section.
> + *
> + * In order to help architectures set both .text and .rodata as read-onl=
y with
> + * memory protections in one shot Linux has typically followed the conve=
ntion
> + * to have the .rodata ELF section follow the .text ELF section on the v=
mlinux

								   in

> + * linker script.
> + *
> + * Linux calls mark_rodata_ro() after freeing .init code and prior to ca=
lling
> + * the first init userspace process.

"first init userspace process" either say "prior to calling init" or
"prior to calling the first userspace process" but both is jambalayed
into something confusing.

> + */
>  void mark_rodata_ro(void);
>  #endif
> =20
> @@ -140,25 +158,70 @@ extern bool initcall_debug;
>  #endif
>   =20
>  #ifndef MODULE
> +/**
> + * DOC: Initcall levels
> + *
> + * When Linux boots the kernel do_initcalls() iterates over each Linux

When Linux boots the kernel?!? You're joking, right?

Just do "During boot, do_initcalls() ..."

> + * initialization level ID and calls all routines embedded on each level=
 ID.
> + * Prior to v2.5.2.3 Linux had only one init level onto which all init
> + * functions folded onto using __initcall(). After v2.5.2.4 Linux split =
up
> + * initcalls into 7 separate initcall subsection levels, each level desc=
ribing
> + * different functionality part of the kernel (commit `9d6ba121b7e17085`_
> + * (v2.5.2.3 -> v2.5.2.4)). In order to remain backward compatible __ini=
tcall()
> + * calls were left mapped to device_initcall().

And why do we need all that git archeology here?

> + * Each init level consists of a dedicated ELF section, init functions a=
re
> + * associated to an init level by linking it into the respective level's
		 with

> + * ELF section.
> + *
> + * Lower order init levels run prior to higher order init levels. Orderi=
ng
> + * inside each initcall level is determined by respective link order.

Those last two sentences are enough.

> + *
> + * .. _9d6ba121b7e17085: https://git.kernel.org/cgit/linux/kernel/git/hi=
story/history.git/commit/?id=9D6ba121b7e17085c95139233686b27a4d4c650e

That's one ugly footnote. Also, the git commit id suffices, you don't
need the URL.

> + */
> =20
>  #ifndef __ASSEMBLY__
> =20
> -/*
> - * initcalls are now grouped by functionality into separate
> - * subsections. Ordering inside the subsections is determined
> - * by link order.=20
> - * For backwards compatibility, initcall() puts the call in=20
> - * the device init subsection.
> +/**
> + * __define_initcall - wrapper for definiting init levels
		       ()

also s/definiting/defining/

Also, this is not what __define_initcall() does. It is not defining init le=
vels.

>   *
> - * The `id' arg to __define_initcall() is needed so that multiple initca=
lls
> - * can point at the same handler without causing duplicate-symbol build =
errors.
> + * @fn: init routine
> + * @id: init level
>   *
> - * Initcalls are run by placing pointers in initcall sections that the
> - * kernel iterates at runtime. The linker can do dead code / data elimin=
ation
> - * and remove that completely, so the initcall sections have to be marked
> - * as KEEP() in the linker script.
> + * Defines a kernel initialization level. A respective linker script ent=
ry
> + * is required to ensure the init level is accounted for and to ensure s=
ymbols
> + * exist for iterating over all functions in the init level. A init level
								An

> + * represents a series of functionality in the kernel.

That sounds yucky.

An init level is a bunch of functions which are called after init_level
- 1 and before init_level + 1.

> + *
> + * Ordering within an initialization level is determined by link order, =
so
> + * for instance if a Makefile had::
> + *
> + *	obj-y +=3D foo.o
> + *	obj-y +=3D bar.o
> + *
> + * And foo.c::
> + *
> + *	subsys_initcall(foo_init);
> + *
> + * And bar.c had::
> + *
> + *	subsys_initcall(bar_init);
> + *
> + * foo_init() would be called prior to bar_init().
> + *
> + * Note that @id in __define_initcall() also enables multiple initcalls
> + * to be created using the same handler for different init levels without
> + * causing duplicate-symbol build errors.
> + *
> + * Initcalls are run by placing start symbols to initcall levels inside =
ELF
> + * sections, the kernel in turn uses these symbols to iterate over each =
init
> + * level at runtime with do_initcall_level(). The end of each init level=
 is
> + * marked by the subsequent's symbol's start address until we reach the =
symbol
> + * ``__initcall_end``.

Needlessly complex, simplify.

> The linker can do dead code / data elimination and each
> + * init level start symbol could be removed completely in this process, =
to
									 . To   <-- new sentence

> + * avoid this each init level start symbols must be marked as 'KEEP()' i=
n the
> + * linker script to avoid any linker optimization heuristic on initcalls.
>   */
> -
>  #define __define_initcall(fn, id) \
>  	static initcall_t __initcall_##fn##id __used \
>  	__attribute__((__section__(".initcall" #id ".init"))) =3D fn;
> diff --git a/include/linux/sections.h b/include/linux/sections.h
> new file mode 100644
> index 000000000000..6771c727bcd1
> --- /dev/null
> +++ b/include/linux/sections.h
> @@ -0,0 +1,87 @@
> +#ifndef _LINUX_SECTIONS_H
> +#define _LINUX_SECTIONS_H
> +/*
> + * Linux de-facto sections

Useless.

> + *
> + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> + *
> + * This program is free software; you can redistribute it and/or modify =
it
> + * under the terms of copyleft-next (version 0.3.1 or later) as published
> + * at http://copyleft-next.org/.
> + */
> +
> +#include <asm/section-core.h>
> +#include <linux/export.h>
> +
> +#ifndef __ASSEMBLY__
> +
> +/**
> + * DOC: Introduction
> + *
> + * Linux defines a set of common helpers which can be used to against it=
s use
						      ^^^^^^^^^^^^^^^^^^^^^^^^^^

??

> + * of standard or custom Linux sections, this section is dedicated to th=
ese

this section is talking about sections, that's too much.

> + * helpers.
> + */
> +
> +/**
> + * LINUX_SECTION_ALIGNMENT - get section alignment
> + *
> + * @name: section name
> + *
> + * Gives you the alignment for the section.
> + */
> +#define LINUX_SECTION_ALIGNMENT(name)	__alignof__(*VMLINUX_SYMBOL(name))

Eeww, too long and it is a getter but doesn't have "GET" in its name.

How about GET_SECTION_ALIGN() ?

And what's with the "LINUX_" prefix - that's like useless use of screen
real estate.

> +
> +/**
> + * LINUX_SECTION_START - get address of start of section

GET_SECTION_START()	-  get address of section start

> + *
> + * @name: section name
> + *
> + * This gives you the start address of the section.
> + * This should give you the address of the first entry.

Huh?

> + *
> + */
> +#define LINUX_SECTION_START(name)	VMLINUX_SYMBOL(name)

Ditto.

> +
> +/**
> + * LINUX_SECTION_END - get address of end of the section
> + *
> + * @name: section name
> + *
> + * This gives you the end address of the section.
> + * This should give you the address of the end of the
> + * section. This will match the start address if the
> + * section is empty.
> + */
> +#define LINUX_SECTION_END(name)	VMLINUX_SYMBOL(name##__end)
> +
> +/**
> + * DECLARE_LINUX_SECTION - Declares a custom Linux section

DECLARE_SECTION() is perfectly fine IMO.

> + *
> + * @type: type of custom Linux section
> + * @name: custom section name
> + *
> + * Declares a read-write custom Linux section
> + */
> +#define DECLARE_LINUX_SECTION(type, name)				\
> +	 extern type VMLINUX_SYMBOL(name)[], \
> +		     VMLINUX_SYMBOL(name##__end)[]
> +
> +/**
> + * DECLARE_LINUX_SECTION_RO - Declares a read-only custom Linux section

DECLARE_SECTION_RO()

> + *
> + * @type: type of custom Linux section
> + * @name: custom section name
> + *
> + * Declares a read-only custom Linux section
> + */
> +#define DECLARE_LINUX_SECTION_RO(type, name)				\
> +	 extern const type VMLINUX_SYMBOL(name)[],			\
> +			   VMLINUX_SYMBOL(name##__end)[]
> +
> +#define __SECTION_CORE(section, core, name, level)			\
> +	#section ".." #core "." #name "." #level
> +
> +#endif /* __ASSEMBLY__ */
> +
> +#endif /* _LINUX_SECTIONS_H */
> --=20

--=20
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
