From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Mon, 08 Aug 2016 15:05:39 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160808150539.GG3296@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
 <20160729100630.GA27271@nazgul.tnic>
In-Reply-To: <20160729100630.GA27271@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel

On Fri, Jul 29, 2016 at 12:06:30PM +0200, Borislav Petkov wrote:
> On Fri, Jul 22, 2016 at 02:24:41PM -0700, Luis R. Rodriguez wrote:
> > A linker table is a data structure that is stitched together from items
> > in multiple object files. Linux has historically implicitly used linker
> > tables for ages, however they were all built in an adhoc manner which
> > requires linker script modifications, per architecture. This adds a
> > general linker table solution so that a new linker table can be
> > implemented by changing C code only. The Linux linker table was
> > originally based on Michael Brown's iPXE's linker table solution but
> > has been significantly modified to fit Linux's use in its integration.
> 
> ...
> 
> > diff --git a/include/asm-generic/tables.h b/include/asm-generic/tables.h
> > new file mode 100644
> > index 000000000000..5cf655590a19
> > --- /dev/null
> > +++ b/include/asm-generic/tables.h
> > @@ -0,0 +1,70 @@
> > +#ifndef _ASM_GENERIC_TABLES_H_
> > +#define _ASM_GENERIC_TABLES_H_
> > +/*
> > + * Linux linker tables
> > + *
> > + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms of copyleft-next (version 0.3.1 or later) as published
> > + * at http://copyleft-next.org/.
> > + */
> > +
> > +#ifdef __KERNEL__
> > +# include <asm/sections.h>
> > +#endif /* __KERNEL__ */
> > +
> > +#define SECTION_TYPE_TABLES	tbl
> 
> What is that for? Section type? Do we have more types or is it useless
> and can go?

We have two types, tables and ranges. But I'll drop that.

> > +
> > +#define SECTION_TBL(section, name, level)				\
> > +	SECTION_TYPE(section, SECTION_TYPE_TABLES, name, level)
> > +
> > +#define SECTION_TBL_ALL(section)					\
> > +	SECTION_TYPE_ALL(section,SECTION_TYPE_TABLES)
> > +
> > +#ifndef section_tbl
> > +# define section_tbl(section, name, level, flags)			\
> > +	 section_type(section, SECTION_TYPE_TABLES, name,		\
> > +		     level, flags)
> 
> That section_type macro is actually saying the following code should
> be in it. Can we make its name have a verb, i.e., something like
> "set_section" to make it more clear?

Sure, thanks changed.

> Also, that type SECTION_TYPE_TABLES looks redundant to me but it
> might start making more sense after I've gone through the rest of the
> series...

I've dropped the type thing.

> > +#endif
> > +
> > +#ifndef section_tbl_any
> > +# define section_tbl_any(section, name, flags)				\
> > +	 section_type(section, SECTION_TYPE_TABLES, name,		\
> > +		     SECTION_ORDER_ANY, flags)
> > +#endif
> > +
> > +#ifndef section_tbl_asmtype
> > +# define section_tbl_asmtype(section, name, level, flags, asmtype)	\
> 
> And here's the confusion: there's "asmtype" but there's also
> SECTION_TYPE_TABLES.
> 
> That asmtype is the *actual* section type in gas speak, i.e., @progbits,
> @note, etc.
> 
> Now *that* should be your type. The SECTION_TYPE_TABLES should be called
> something else or completely gone.

Right, OK dropped and only kept type for this.

> > +	 section_type_asmtype(section, SECTION_TYPE_TABLES, name,	\
> > +			     level, flags, asmtype)
> > +#endif
> > +
> > +#ifndef push_section_tbl
> > +# define push_section_tbl(section, name, level, flags)			\
> > +	 push_section_type(section, SECTION_TYPE_TABLES, name,		\
> > +			  level, flags)
> > +#endif
> > +
> > +#ifndef push_section_tbl_any
> > +# define push_section_tbl_any(section, name, flags)			\
> > +	 push_section_type(section, SECTION_TYPE_TABLES, name,		\
> > +			  SECTION_ORDER_ANY, flags)
> > +#endif
> > +
> > +#if defined(__ASSEMBLER__) || defined(__ASSEMBLY__)
> > +
> > +# ifndef DECLARE_SECTION_TBL
> > +#  define DECLARE_SECTION_TBL(section, name)				\
> > +  push_section_tbl(section, name,,) ;					\
> > +  .globl name ;								\
> > +name: ;									\
> > +  .popsection								\
> > +									\
> > +  push_section_tbl(section, name, ~,) ;					\
> > +  .popsection
> > +# endif
> 
> #endif /* DECLARE_SECTION_TBL */
> 
> Btw, what does that macro do? I don't see it used anywhere.

It can be used in asm code to do actually what DEFINE_LINKTABLE() does but now
that I think about it this should then match the name and we'd need one per
standard section, as we have for linker table in C code. I've demo'd this
use in the userspace mockup git tree but with section ranges. In the meantime
I've dropped these macros from this series for now. When we need them we can add
them.

> > + * userspace linker-table tree [1].  This repository can be used for ease of
> > + * testing of extensions and sampling of changes prior to inclusion into Linux,
> > + * it is intended to be kept up to date to match Linux's solution. Contrary to
> 
> Keeping different pieces of code in sync is always a PITA.
> 
> Can we automatically extract the kernel linker tables into a standalone
> userspace pile of C code for experimentation? I.e., something like
> 
> make linker_tables_app

Sure. Will shoot for that.

> > + * enables you to always force compiling of select features that one wishes to
> > + * avoid bit-rot while still enabling you to disable linking feature code into
> > + * the final kernel image if the features have been disabled via Kconfig.
> 
> So this sounds to me like the main reason for linker tables is solving
> the bitrot problem. And I don't think that is the main reason for them,
> is it?

Not for us, it just one added benefit that's possible from it.

> Because we can address the bitrot issue by simply building randconfigs,
> without even touching the kernel. So why do we need those linker tables?

As you noted its described better below.

> > + * Linux's linker tables allows for developers to be selective over where one
> > + * wishes to take advantage of the optional feature of forcing compilation and
> > + * only linking in enabled features.
> > + *
> > + * To use linker tables and to optionally take advantage of avoiding code
> > + * bit-rot, feature code should be implemented in separate C files, and should
> > + * be designed to always be compiled -- they should not be guarded with a C
> > + * code #ifdef CONFIG_FOO statements, consideration must also be taken for
> > + * sub-features which depend on the main CONFIG_FOO option, as they will be
> > + * disabled if they depend on CONFIG_FOO and therefore not compiled. To force
> > + * compilation and only link when features are needed a new optional target
> > + * table-y can be used on Makefiles, documented below.
> 
> Ok, this is more like it. Linker tables actually diminish the Kconfig
> complexity. I'd lead with that.

OK will be sure to clarify all this and thanks for the typo fixes, etc.

> > + * will result with the feature on your binary only if you've enabled
> > + * CONFIG_FOO, however using table-$(CONFIG_FOO) will always force compilation,
> > + * this is why avoiding code bit-rot is an optional fature for Linux linker
> 
> "fature" - please run it through spellchecker.
> 
> Btw, I'm afraid this "table-$(CONFIG" thing might be misused by people
> wanting their stuff to be compile-tested and we'd end up practically
> building an allyesconfig each time.

This should be decided per subsystem maintainer.

> So how can I disable those table-* things from even getting built? Avoid
> using table-y? But then everything declared table-y will be built
> unconditionally. I don't think I like that. :-\

I suppose we could make this configurable... But frankly I would prefer to
instead just document that this use should be carefully considered instead,
and let this be up to the maintainers. We can make it easily configurable so
we can do that later becomes a required, I don't think its needed though
given maintainers should use it only when needed.

> 
> > + * tables.
> > + */
> > +
> > +/**
> > + * DOC: How linker tables simplify inits
> > + *
> > + * Traditionally, we would implement features in C code as follows:
> 
> Ok, so *this* is your main reason for linker tables - not fixing the
> bit-rot problem. The text on the bit-rot problem should come second and
> be the byproduct of linker tables.

Will fix ordering.

> Also, this section here should be the opening section in the document
> explaining linker tables. I'd like to read about what it is first, then
> read what else they're good for.

Sure.

> > + *
> > + *	foo_init();
> > + *
> > + * You'd then have a foo.h which would have:
> > + *
> > + *	#ifdef CONFIG_FOO
> > + *	#else
> > + *	static inline void foo(void) { }
> > + *	#endif
> > + *
> > + * With linker tables this is no longer necessary as your init routines would
> > + * be implicit, you'd instead call:
> > + *
> > + *	call_init_fns();
> > + *
> > + * call_init_fns() would call all functions present in your init table and if
> > + * and only if foo.o gets linked in, then its initialisation function will be
> > + * called, whether you use obj-$(CONFIG_FOO) or table-$(CONFIG_FOO).
> > + *
> > + * The linker script takes care of assembling the tables for us. All of our
> > + * table sections have names of the format SECTION_NAME*.tbl.NAME.N. Here
> 
> The fact that you actually say "tbl" here shows again SECTION_TYPE_TABLES is
> redundant.

I've nuked SECTION_TYPE_TABLES and SECTION_TYPE_RANGES

> > +/**
> > + * DOC: Linker table helpers
> > + *
> > + * These are helpers for linker tables.
> > + */
> 
> I'm assuming those are all needed and we're not adding them just for
> completeness...
> 
> Otherwise, they'll bit-rot. :-))))

The ones we didn't have uses for yet I've nuked now.

  Luis
