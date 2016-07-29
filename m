From: Borislav Petkov <bp@alien8.de>
Date: Fri, 29 Jul 2016 10:06:30 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160729100630.GA27271@nazgul.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-

On Fri, Jul 22, 2016 at 02:24:41PM -0700, Luis R. Rodriguez wrote:
> A linker table is a data structure that is stitched together from items
> in multiple object files. Linux has historically implicitly used linker
> tables for ages, however they were all built in an adhoc manner which
> requires linker script modifications, per architecture. This adds a
> general linker table solution so that a new linker table can be
> implemented by changing C code only. The Linux linker table was
> originally based on Michael Brown's iPXE's linker table solution but
> has been significantly modified to fit Linux's use in its integration.

...

> diff --git a/include/asm-generic/tables.h b/include/asm-generic/tables.h
> new file mode 100644
> index 000000000000..5cf655590a19
> --- /dev/null
> +++ b/include/asm-generic/tables.h
> @@ -0,0 +1,70 @@
> +#ifndef _ASM_GENERIC_TABLES_H_
> +#define _ASM_GENERIC_TABLES_H_
> +/*
> + * Linux linker tables
> + *
> + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of copyleft-next (version 0.3.1 or later) as published
> + * at http://copyleft-next.org/.
> + */
> +
> +#ifdef __KERNEL__
> +# include <asm/sections.h>
> +#endif /* __KERNEL__ */
> +
> +#define SECTION_TYPE_TABLES	tbl

What is that for? Section type? Do we have more types or is it useless
and can go?

> +
> +#define SECTION_TBL(section, name, level)				\
> +	SECTION_TYPE(section, SECTION_TYPE_TABLES, name, level)
> +
> +#define SECTION_TBL_ALL(section)					\
> +	SECTION_TYPE_ALL(section,SECTION_TYPE_TABLES)
> +
> +#ifndef section_tbl
> +# define section_tbl(section, name, level, flags)			\
> +	 section_type(section, SECTION_TYPE_TABLES, name,		\
> +		     level, flags)

That section_type macro is actually saying the following code should
be in it. Can we make its name have a verb, i.e., something like
"set_section" to make it more clear?

Also, that type SECTION_TYPE_TABLES looks redundant to me but it
might start making more sense after I've gone through the rest of the
series...

> +#endif
> +
> +#ifndef section_tbl_any
> +# define section_tbl_any(section, name, flags)				\
> +	 section_type(section, SECTION_TYPE_TABLES, name,		\
> +		     SECTION_ORDER_ANY, flags)
> +#endif
> +
> +#ifndef section_tbl_asmtype
> +# define section_tbl_asmtype(section, name, level, flags, asmtype)	\

And here's the confusion: there's "asmtype" but there's also
SECTION_TYPE_TABLES.

That asmtype is the *actual* section type in gas speak, i.e., @progbits,
@note, etc.

Now *that* should be your type. The SECTION_TYPE_TABLES should be called
something else or completely gone.

> +	 section_type_asmtype(section, SECTION_TYPE_TABLES, name,	\
> +			     level, flags, asmtype)
> +#endif
> +
> +#ifndef push_section_tbl
> +# define push_section_tbl(section, name, level, flags)			\
> +	 push_section_type(section, SECTION_TYPE_TABLES, name,		\
> +			  level, flags)
> +#endif
> +
> +#ifndef push_section_tbl_any
> +# define push_section_tbl_any(section, name, flags)			\
> +	 push_section_type(section, SECTION_TYPE_TABLES, name,		\
> +			  SECTION_ORDER_ANY, flags)
> +#endif
> +
> +#if defined(__ASSEMBLER__) || defined(__ASSEMBLY__)
> +
> +# ifndef DECLARE_SECTION_TBL
> +#  define DECLARE_SECTION_TBL(section, name)				\
> +  push_section_tbl(section, name,,) ;					\
> +  .globl name ;								\
> +name: ;									\
> +  .popsection								\
> +									\
> +  push_section_tbl(section, name, ~,) ;					\
> +  .popsection
> +# endif

#endif /* DECLARE_SECTION_TBL */

Btw, what does that macro do? I don't see it used anywhere.

> +
> +#endif /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
> +
> +#endif /* _ASM_GENERIC_TABLES_H_ */


...


> diff --git a/include/linux/tables.h b/include/linux/tables.h
> new file mode 100644
> index 000000000000..89d46f4c5739
> --- /dev/null
> +++ b/include/linux/tables.h
> @@ -0,0 +1,597 @@
> +#ifndef _LINUX_LINKER_TABLES_H
> +#define _LINUX_LINKER_TABLES_H
> +/*
> + * Linux linker tables
> + *
> + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of copyleft-next (version 0.3.1 or later) as published
> + * at http://copyleft-next.org/.
> + */
> +#include <linux/sections.h>
> +#ifdef __KERNEL__
> +# include <asm/tables.h>
> +#endif /* __KERNEL__ */
> +
> +#ifndef __ASSEMBLY__
> +
> +/**
> + * DOC: Introduction
> + *
> + * A linker table is a data structure that is stitched together from items
> + * in multiple object files. Linux has historically implicitly used linker

s/historically//

"for ages" already says "historically" :-)

> + * tables for ages, however they were all built in an adhoc manner which
> + * requires linker script modifications, per architecture. This linker table

s/,//

> + * solution provides a general linker table facility so that a new linker table
> + * can be implemented by changing C code only.
> + *
> + * Linker tables help you simplify init sequences by using ELF sections, linker
> + * build time selective sorting (disabled options get ignored), and can
> + * optionally also be used to help you avoid code bit-rot due to #ifdery

"ifdeffery"

> + * collateral.

... and I don't understand what "ifdeffery collateral" means.

> + */
> +
> +/**
> + * DOC: Linker table provenance and userspace testing
> + *
> + * The Linux implementation of linker tables is derivative of iPXE linker
> + * table's solution (iPXE commit 67a10ef000cb7 [0]).  To see how this code
> + * evolved or to extend and test and use this code in userspace refer to the

"... to extend, test and use... "

> + * userspace linker-table tree [1].  This repository can be used for ease of
> + * testing of extensions and sampling of changes prior to inclusion into Linux,
> + * it is intended to be kept up to date to match Linux's solution. Contrary to

Keeping different pieces of code in sync is always a PITA.

Can we automatically extract the kernel linker tables into a standalone
userspace pile of C code for experimentation? I.e., something like

make linker_tables_app

or so...

> + * iPXE's solution, which strives to force compilation of everything using

s/,//

> + * linker tables, Linux's solution allows for developers to be selective over
> + * where one wishes to force compilation, this then is just an optional feature
> + * for the Linux linker table solution.
> + *
> + * [0] git://git.ipxe.org/ipxe.git
> + *
> + * [1] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linker-tables.git/
> + */
> +
> +/**
> + * DOC: The code bit-rot problem
> + *
> + * Overuse of C #ifdefs can be problematic for certain types of code.  Linux
> + * provides a rich array of features, but all these features take up valuable
> + * space in a kernel image. The traditional solution to this problem has been
> + * for each feature to have its own Kconfig entry and for the respective code
> + * to be wrapped around #ifdefs, allowing the feature to be compiled in only
> + * if desired.

"... if enabled in Kconfig."

> + *
> + * The problem with this is that over time it becomes very difficult and time
> + * consuming to compile, let alone test, all possible versions of Linux. Code

					    "all possible Kconfig configurations."

> + * that is not typically used tends to suffer from bit-rot over time. It can
> + * become difficult to predict which combinations of compile-time options will
> + * result in code that can compile and link correctly.
> + */
> +
> +/**
> + * DOC: Avoiding the code bit-rot problem when desirable
> + *
> + * To solve the code bit-rot problem linker tables can be used on Linux, it

"One way to solve this ..."					 "... on Linux. It enables..."

> + * enables you to always force compiling of select features that one wishes to
> + * avoid bit-rot while still enabling you to disable linking feature code into
> + * the final kernel image if the features have been disabled via Kconfig.

So this sounds to me like the main reason for linker tables is solving
the bitrot problem. And I don't think that is the main reason for them,
is it?

Because we can address the bitrot issue by simply building randconfigs,
without even touching the kernel. So why do we need those linker tables?

> + * Linux's linker tables allows for developers to be selective over where one
> + * wishes to take advantage of the optional feature of forcing compilation and
> + * only linking in enabled features.
> + *
> + * To use linker tables and to optionally take advantage of avoiding code
> + * bit-rot, feature code should be implemented in separate C files, and should
> + * be designed to always be compiled -- they should not be guarded with a C
> + * code #ifdef CONFIG_FOO statements, consideration must also be taken for
> + * sub-features which depend on the main CONFIG_FOO option, as they will be
> + * disabled if they depend on CONFIG_FOO and therefore not compiled. To force
> + * compilation and only link when features are needed a new optional target
> + * table-y can be used on Makefiles, documented below.

Ok, this is more like it. Linker tables actually diminish the Kconfig
complexity. I'd lead with that.

> + *
> + * Currently only built-in features are supported, modular support is not
> + * yet supported,

"... modular support ... supported ... " Avoid tautology pls.

> however you can make use of sub-features for modules
> + * if they are independent and can simply be linked into modules.
> + */
> +
> +/**
> + * DOC: Using target table-y and table-n
> + *
> + * Let's assume we want to always force compilation of feature FOO in the
> + * kernel but avoid linking it. When you enable the FOO feature via Kconfig
> + * you'd end up with:
> + *
> + *	#define CONFIG_FOO 1
> + *
> + * You typically would then just use this on your Makefile to selectively

s/on/in/

> + * compile and link the feature:
> + *
> + *	obj-$(CONFIG_FOO) += foo.o
> + *
> + * You could instead optionally use the new linker table object:
> + *
> + *	table-$(CONFIG_FOO) += foo.o
> + *
> + * Alternatively, this would be the equivalent of listing:
> + *
> + *	extra += foo.o
> + *	obj-$(CONFIG_FOO) += foo.o
> + *
> + * Both are mechanisms which can be used to take advantage of forcing
> + * compilation with linker tables, however making use of table-$(CONFIG_FOO)
> + * is encouraged as it helps with annotating linker tables clearly where
> + * compilation is forced.
> + */
> +
> +/**
> + * DOC: Opting out of forcing compilation
> + *
> + * If you want to opt-out of forcing compilation you would use the typical
> + * obj-$(CONFIG_FOO) += foo.o and foo.o will only be compiled and linked
> + * in when enabled. Using both table-$(CONFIG_FOO) and obj-($CONFIG_FOO)

"... when CONFIG_FOO is enabled."

> + * will result with the feature on your binary only if you've enabled
> + * CONFIG_FOO, however using table-$(CONFIG_FOO) will always force compilation,
> + * this is why avoiding code bit-rot is an optional fature for Linux linker

"fature" - please run it through spellchecker.

Btw, I'm afraid this "table-$(CONFIG" thing might be misused by people
wanting their stuff to be compile-tested and we'd end up practically
building an allyesconfig each time.

So how can I disable those table-* things from even getting built? Avoid
using table-y?

But then everything declared table-y will be built unconditionally. I don't
think I like that. :-\

> + * tables.
> + */
> +
> +/**
> + * DOC: How linker tables simplify inits
> + *
> + * Traditionally, we would implement features in C code as follows:

Ok, so *this* is your main reason for linker tables - not fixing the
bit-rot problem. The text on the bit-rot problem should come second and
be the byproduct of linker tables.

Also, this section here should be the opening section in the document
explaining linker tables. I'd like to read about what it is first, then
read what else they're good for.

> + *
> + *	foo_init();
> + *
> + * You'd then have a foo.h which would have:
> + *
> + *	#ifdef CONFIG_FOO
> + *	#else
> + *	static inline void foo(void) { }
> + *	#endif
> + *
> + * With linker tables this is no longer necessary as your init routines would
> + * be implicit, you'd instead call:
> + *
> + *	call_init_fns();
> + *
> + * call_init_fns() would call all functions present in your init table and if
> + * and only if foo.o gets linked in, then its initialisation function will be
> + * called, whether you use obj-$(CONFIG_FOO) or table-$(CONFIG_FOO).
> + *
> + * The linker script takes care of assembling the tables for us. All of our
> + * table sections have names of the format SECTION_NAME*.tbl.NAME.N. Here

The fact that you actually say "tbl" here shows again SECTION_TYPE_TABLES is
redundant.

> + * SECTION_NAME is one of the standard sections in include/linux/sections.h,
> + * and NAME designates the specific use case for the linker table, the table.

								s/, the table//

<--- new paragraph starts here

> + * N is a digit decimal number used to impose an "order level" upon the tables

	digit *and* decimal number? :-)

> + * if required. NN= (empty string) is reserved for the symbol indicating "table

NN= or N= ?

> + * start", and N=~ is reserved for the symbol indicating "table end". In order
> + * for the call_init_fns() to work behind the scenes the custom linker script
> + * would need to define the beginning of the table, the end of the table, and
> + * in between it should use SORT() to give order-level effect. Now, typically

So basically N makes the section names sortable...

> + * such type of requirements would require custom linker script modifications

Duude, you're killing me: "such type of requirements would require"

> + * but Linux's linker tables builds on top of already existing standard Linux

				build

> + * ELF sections, each with different purposes. This lets you build and add
> + * new tables without needing custom linker script modifications. This is
> + * also done to support all architectures. All that is needed then is to
> + * ensure a respective common linker table entry is added to the shared
> + * include/asm-generic/vmlinux.lds.h.

<-- new paragraph starts here:

> There should be a respective:
> + *
> + *	*(SORT(SECTION_TBL_ALL(SECTION_NAME)))
> + *
> + * entry for each type of supported section there. If your SECTION_NAME
> + * is not yet supported, consider adding support for it.
> + *
> + * The order-level is really only a helper, if only one order level is

order-level??

What that?

> + * used, the next contributing factor to order is the order of the code
> + * in the C file, and the order of the objects in the Makefile. Using
> + * an order level then should not really be needed in most cases, its
> + * use however enables to compartamentalize code into tables where ordering
> + * through C file or through the Makefile would otherwise be very difficult
> + * or if one wanted to enable very specific initialization semantics.
> + *
> + * As an example, suppose that we want to create a "frobnicator"
> + * feature framework, and allow for several independent modules to
> + * provide frobnicating services. Then we would create a frob.h
> + * header file containing e.g.
> + *
> + *	struct frobnicator {
> + *		const char *name;
> + *		void (*frob) (void);
> + *	};
> + *
> + *	DECLARE_LINKTABLE(struct frobnicator, frobnicator_fns);
> + *
> + * Any module providing frobnicating services would look something
> + * like
> + *
> + *	#include "frob.h"
> + *	static void my_frob(void) {
> + *		... Do my frobnicating
> + *	}
> + *	LINKTABLE_INIT_DATA(frobnicator_fns, all) my_frobnicator = {
> + *		.name = "my_frob",
> + *		.frob = my_frob,
> + *	};
> + *
> + * The central frobnicator code (frob.c) would use the frobnicating
> + * modules as follows
> + *
> + *	#include "frob.h"
> + *
> + *	void frob_all(void) {
> + *		struct frob *frob;
> + *
> + *		LINKTABLE_FOR_EACH(frob, frobnicator_fns) {
> + *			pr_info("Calling frobnicator \"%s\"\n", frob->name);
> + *			frob->frob();
> + *		}
> + *	}
> + */
> +
> +/**
> + * DOC: Linker table helpers
> + *
> + * These are helpers for linker tables.
> + */

I'm assuming those are all needed and we're not adding them just for
completeness...

Otherwise, they'll bit-rot. :-))))

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
