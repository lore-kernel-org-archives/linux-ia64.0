From: Nicholas Piggin <npiggin@gmail.com>
Date: Wed, 24 Aug 2016 03:51:41 +0000
Subject: Re: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <20160824135141.2c8f06ec@roar.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
        <1471642454-5679-5-git-send-email-mcgrof@kernel.org>
        <20160823112633.7d482e62@roar.ozlabs.ibm.com>
        <20160823173306.GA3296@wotan.suse.de>
In-Reply-To: <20160823173306.GA3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix

On Tue, 23 Aug 2016 19:33:06 +0200
"Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> On Tue, Aug 23, 2016 at 11:26:33AM +1000, Nicholas Piggin wrote:
> > On Fri, 19 Aug 2016 14:34:02 -0700
> > mcgrof@kernel.org wrote:  
> > > +/**
> > > + * DOC: Standard ELF section use in Linux
> > > + *
> > > + * Linux makes use of the standard ELF sections, this sections documents
> > > + * these.
> > > + */
> > > +
> > > +/**
> > > + * DOC: SECTION_RODATA
> > > + *
> > > + * Macro name for code which must be protected from write access, read only
> > > + * data.
> > > + */
> > > +#define SECTION_RODATA			.rodata  
> > 
> > These, for example. The exact name of the section is important in linker
> > scripts and asm, so I can't see the benefit of hiding it. I could be
> > missing the bigger picture.  
> 
> There's two goals by using a macro for these core names. One is to allow us
> to easily aggregate documentation in central place for each, the second is
> to then provide more easily grep'able helpers so we can use them when devising
> extensions or using them in extensions which further customize the sections
> in the kernel.

Documentation is good, but not necessary to have the extra name indirection.
Sections tend (not always, but it would be nice if they did) to follow the
.name convention, which makes them reasonably easy to grep for. They are also
the names you'll be grepping for when you look at disassembly.


> > > +/**
> > > + * DOC: SECTION_TEXT
> > > + *
> > > + * Macro name used to annotate code (functions) used during regular
> > > + * kernel run time. This is combined with `SECTION_RODATA`, only this
> > > + * section also allows for execution.
> > > + *
> > > + */
> > > +#define SECTION_TEXT			.text  
> > 
> > I can't see how these comments are right. .rodata doesn't seem like it
> > should be combined with .text, and is not currently on powerpc. I think
> > it's for data, not code.  
> 
> On x86 and powerpc .rodata follows .text.

But follows is not the same as combined. And together with the comment that
RODATA is for code (which is wrong, it's data), it make it seem like it
is actually combined.


> On power currently the comment
> above in .rodata is:
> 
> /* Text, read only data and other permanent read-only sections */
> 
> When this was introduced however read commit 14cf11af6cf60 ("powerpc: Merge
> enough to start building in arch/powerpc.")
> 
> /* Read-only sections, merged into text segment: */
> 
> The format and style of putting rodata after text is kept from the older
> commits.
> 
> This begs the question. What the hell is this thing talking about?
> 
> On Linux this is done via mark_rodata_ro() on init/main.c when CONFIG_DEBUG_RODATA
> on architectures that support it. Architectures that implement this typically use
> issues set_memory_ro() -- on x86 a start address used is PFN_ALIGN(_text) with
> an end address of &__end_rodata_hpage_align.
> 
> When architectures do not have CONFIG_DEBUG_RODATA() you end up with:
> 
> static inline void mark_readonly(void)                                          
> {                                                                               
>         pr_warn("This architecture does not have kernel memory protection.\n"); 
> }
> 
> So -- I should I clarify then in Linux we strive to have helpers adjust text and
> rodata set to ro with memory protection implemented via mark_readonly(). Architectures
> that do not support memory protection will lack a mark_readonly() implementation.

Right, I wasn't talking about arch implementation of how the ro
protection is done, so much as just the comments being a bit misleading.


> For now I figured a less controversial introduction to the documentation as
> bland as it was above in my original patch would suffice, we can then expand on
> it with something like the above. Thoughts?

I think comments are one of the key features of this patch series (or at
least this patch, I've not looked through the others so much yet). I'm no
expert on linker stuff, but I think a lot of arch maintainers aren't
necessarily either so you tend to get a lot of copy and paste without
always people knowing what exactly is happening. It would be really good
to have some longer explanations and justifications/examples IMO. So I
don't think that would be controversial if you wanted to expand on it.


> > > +/*
> > > + * These section _ALL() helpers are for use on linker scripts and helpers
> > > + */
> > > +#define SECTION_ALL(__section)						\
> > > +	__section##.*  
> > 
> > This is another example. We know what .text.* does in the linker scripts
> > -- it's self documenting. But SECTION_ALL(.text)? I'm not sure that's an
> > improvement. Actually I saw it in the linker script changes and had to
> > come find the definition because I was a bit mislead:
> > 
> > SECTION_ALL(.text)
> > 
> > Initially I would expect this to be
> > 
> > .text*
> > 
> > Not
> > 
> > .text.*
> > 
> > The latter does not grab the .text section!  
> 
> Its not intended to grab .text but rather its for helpers that provide customizations
> based on a core section as base, in this case given your example it would be used by
> section ranges and linker tables for .text. Both section ranges and linker tables
> use postfix .something for their customizations. The SECTION_ALL() macro then is
> a helper for customizations on a core section.

Right, it's just that .text.* is *immediately* obvious. SECTION_ALL() is not.


> If the name is misleading would SECTION_CORE_ALL() be better with some documentation
> explaining this and the above goal ?

I don't know... not to be glib, but .section.* would be better and not require
documentation.

CORE does not really add anything as far as I can see. Other types of .text including
ones which are automatically generated by the compiler, for better or worse, are
.text.x sections too.

I would like to see more standardisation of naming convention -- some sections start
with .., some start with no dots, some use . to separate logical "subsections", others
use underscores or something else. I just don't see it would be a problem to simply
use the raw names and linker wildcards for it.


> > > +/*
> > > + * As per gcc's documentation a common asm separator is a new line followed
> > > + * by tab [0], it however seems possible to also just use a newline as its
> > > + * the most commonly empirically observed semantic and folks seem to agree
> > > + * this even works on S390. In case your architecture disagrees you may
> > > + * override this and define your own and keep the rest of the macros.
> > > + *
> > > + * [0] https://gcc.gnu.org/onlinedocs/gcc/Basic-Asm.html#Basic-Asm
> > > + */
> > > +# ifndef ASM_CMD_SEP
> > > +#  define ASM_CMD_SEP	"\n"
> > > +# endif  
> > 
> > This does not seem like it belongs here. The name is fairly ugly too.  
> 
> Help me bikeshed, any name suggestions?

BTW, I'm not trying to bikeshed :) This doesn't affect the value of your
patch at all, it was just an offhand thing I saw.

> 
> > I guess something might be needed like this when dealing with generic
> > as directives common to all architectures, though.  
> 
> Indeed, it actually seems we don't have much in this area, so this is small
> baby step in that direction.
> 
> > I would say include/asm-generic/asm.h should be a better place.  
> 
> I thought about this -- I'd be adding a new asm-generic/asm.h -- are folks OK
> with that right now? Or should we do that as a secondary step ? I preferred to
> do this as a secondary step as this series is long enough already and there is
> quite a bit that can be dumped in a common asm-generic/asm.h, a few thoughts
> on this already:
> 
>  o x86's asm/asm.h's use of __ASM_FORM() and include/linux/stringify.h share
>    some traits which deserve possible consideration / rebranding.
>  o Since C asm() just wrap things in strings defining a core set of
>    helpers for a task seems justifiable, so for example we have
>    __set_section_core_type(). Raw asm code then would use __set_section_core_type()
>    directly and C asm() would just __stringify() it.
> 
> I figured a bit of bikeshedding would be possible here, so I decided to leave
> this for a later set of patches. But indeed, I agree with you. If we want
> this meshed out now.. let me know and lets bikeshed away...

It's fine, I don't mind too much. I think asm-generic/asm.h should be
fine for generic asm'isms though. Or assembler.h to match compiler.h.


> > > diff --git a/include/linux/sections.h b/include/linux/sections.h
> > > new file mode 100644
> > > index 000000000000..f21c6ee88ded
> > > --- /dev/null
> > > +++ b/include/linux/sections.h
> > > @@ -0,0 +1,111 @@
> > > +#ifndef _LINUX_SECTIONS_H
> > > +#define _LINUX_SECTIONS_H
> > > +/*
> > > + * Linux de-facto sections
> > > + *
> > > + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> > > + *
> > > + * This program is free software; you can redistribute it and/or modify it
> > > + * under the terms of copyleft-next (version 0.3.1 or later) as published
> > > + * at http://copyleft-next.org/.
> > > + */
> > > +
> > > +#include <asm/section-core.h>
> > > +#include <linux/export.h>
> > > +
> > > +#ifndef __ASSEMBLY__
> > > +
> > > +/**
> > > + * DOC: Introduction
> > > + *
> > > + * Linux defines a set of common helpers which can be used to against its use
> > > + * of standard or custom Linux sections, this section is dedicated to these
> > > + * helpers.  
> > 
> > I'm still not quite sure what a Linux de-facto/standard/common section is
> > after this. Are they output sections?  
> 
> We have ELF standard sections, and we have then sections which Linux has introduced
> over the years which are now just known to be expected part of Linux, such as init
> stuff which we free after boot. The combination of the ELF standard sections and
> series of expected sections in Linux across all architectures is what this refers
> to as Linux de-facto/standard/common sections. The header file is intended to
> document these, step by step, and also provide helpers which allow further
> customizations based on these sections.

Well but your macros are not linker sections. They are "Linux sections", which
appear to give you a start and end symbol name, but does not direct the linker
to create a specific output section. I just can't work out what exactly is a
"custom Linux section", and what DECLARE_LINUX_SECTION(), for example, actaully
gives you.


Thanks,
Nick
