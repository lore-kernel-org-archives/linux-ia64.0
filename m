From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 20 May 2003 04:40:20 +0000
Subject: Re: [Linux-ia64] offsets.h generation
Message-Id: <marc-linux-ia64-105590723705956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705941@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705941@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 20, 2003 at 11:26:31AM +1000, Peter Chubb wrote:
> 
> OK, here's a patch that does it that way.
Much better, thanks. A few more comments.
I assume that deletion of files in arch/ia64/tools will follow
in seperate cset.

> Because some of the needed
> header files in turn depend on a symbol from offsets.h, I had to
> create a dummy one `by hand' if it didn't previously exist.
> A timestamp file, include/asm-ia64/.offsets.h.stamp, tracks when this
> was done so that 'make' after 'make clean' works; and 'make' after
> 'make' works.

David: Can we remove this circular dependency to get rid of
this ugly workaround?

> -CLEAN_FILES += include/asm-ia64/offsets.h vmlinux.gz bootloader
> +CLEAN_FILES += include/asm-ia64/offsets.h include/asm-ia64/.offsets.h.stamp vmlinux.gz bootloader

Break in two lines.

> -prepare: include/asm-ia64/offsets.h
> +prepare: include/asm-ia64/offsets.h 

> +arch/$(ARCH)/kernel/asm-offsets.s: include/asm include/linux/version.h \
> +				   include/config/MARKER include/asm-$(ARCH)/.offsets.h.stamp

Dependency on include/asm include/linux/version.h and include/config/MARKER
is not needed.
I would prefer to have dependencies for arch/$(ARCH)/kernel/asm-offsets.s
located in kernel/Makefile from where the .s fil is actually build.
Note that it is the general %.s : %.c rule from the top-level
Makefile that kicks in and make sure the .s file get build when needed.

> +
> +include/asm-$(ARCH)/.offsets.h.stamp: 
> +	[ -f include/asm-$(ARCH)/offsets.h ] || echo "#define IA64_TASK_SIZE 0" > include/asm-$(ARCH)/offsets.h
> +	touch $@

So this part should go in kernel/MAkefile as well.

> +#include "../kernel/sigframe.h"
This include should be without "../kernel".

Thanks for cleaning this up.

	Sam

