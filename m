From: Nicholas Piggin <npiggin@gmail.com>
Date: Tue, 23 Aug 2016 01:26:33 +0000
Subject: Re: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <20160823112633.7d482e62@roar.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
        <1471642454-5679-5-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-5-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mcgrof@kernel.org
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix

On Fri, 19 Aug 2016 14:34:02 -0700
mcgrof@kernel.org wrote:

> From: "Luis R. Rodriguez" <mcgrof@kernel.org>
> 
> Linux makes extensive use of custom ELF header sections,
> documentation for these are well scatterred. Unify this
> documentation in a central place and provide helpers to
> build custom Linux sections.
> 
> This also generalizes sections code to enable avoiding
> modifying the linker scripts when we want to add new
> custom Linux sections. In order to make this generally
> useful we need to ensure all architectures can make use of
> core section helpers but that they can also override should
> this be needed. Instead of relying on section.h this adds
> a sections-core.h since this will be targetted to be safe
> to be used on asm code, linker scripts and C code.

Hi Luis,

The linker stuff in the kernel definitely needs someone to take care
of it, so it's good to see some effort to clean up and generalize some
of it.

Not all your patches seem to depend on each other, so it might be good
to push some of the cleanups through first. And some of these core
patches could go in bit by bit if necessary.

On this specific patch: while the as and ld sections syntax and
semantics are pretty ugly and esoteric, I question how much of this is
actually an improvement. Some of it seems to just be wrapping one name
with another, or hiding some behaviour in a maybe not intuitive way.


> +/**
> + * DOC: Standard ELF section use in Linux
> + *
> + * Linux makes use of the standard ELF sections, this sections documents
> + * these.
> + */
> +
> +/**
> + * DOC: SECTION_RODATA
> + *
> + * Macro name for code which must be protected from write access, read only
> + * data.
> + */
> +#define SECTION_RODATA			.rodata

These, for example. The exact name of the section is important in linker
scripts and asm, so I can't see the benefit of hiding it. I could be
missing the bigger picture.


> +/**
> + * DOC: SECTION_TEXT
> + *
> + * Macro name used to annotate code (functions) used during regular
> + * kernel run time. This is combined with `SECTION_RODATA`, only this
> + * section also allows for execution.
> + *
> + */
> +#define SECTION_TEXT			.text

I can't see how these comments are right. .rodata doesn't seem like it
should be combined with .text, and is not currently on powerpc. I think
it's for data, not code.


> +/*
> + * These section _ALL() helpers are for use on linker scripts and helpers
> + */
> +#define SECTION_ALL(__section)						\
> +	__section##.*

This is another example. We know what .text.* does in the linker scripts
-- it's self documenting. But SECTION_ALL(.text)? I'm not sure that's an
improvement. Actually I saw it in the linker script changes and had to
come find the definition because I was a bit mislead:

SECTION_ALL(.text)

Initially I would expect this to be

.text*

Not

.text.*

The latter does not grab the .text section!


> +/*
> + * As per gcc's documentation a common asm separator is a new line followed
> + * by tab [0], it however seems possible to also just use a newline as its
> + * the most commonly empirically observed semantic and folks seem to agree
> + * this even works on S390. In case your architecture disagrees you may
> + * override this and define your own and keep the rest of the macros.
> + *
> + * [0] https://gcc.gnu.org/onlinedocs/gcc/Basic-Asm.html#Basic-Asm
> + */
> +# ifndef ASM_CMD_SEP
> +#  define ASM_CMD_SEP	"\n"
> +# endif

This does not seem like it belongs here. The name is fairly ugly too.
I guess something might be needed like this when dealing with generic
as directives common to all architectures, though. I would say
include/asm-generic/asm.h should be a better place.


> diff --git a/include/linux/sections.h b/include/linux/sections.h
> new file mode 100644
> index 000000000000..f21c6ee88ded
> --- /dev/null
> +++ b/include/linux/sections.h
> @@ -0,0 +1,111 @@
> +#ifndef _LINUX_SECTIONS_H
> +#define _LINUX_SECTIONS_H
> +/*
> + * Linux de-facto sections
> + *
> + * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
> + *
> + * This program is free software; you can redistribute it and/or modify it
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
> + * Linux defines a set of common helpers which can be used to against its use
> + * of standard or custom Linux sections, this section is dedicated to these
> + * helpers.

I'm still not quite sure what a Linux de-facto/standard/common section is
after this. Are they output sections?

I think it would be reasonable to drop the LINUX_ prefix and references to
Linux.

Thanks,
Nick
