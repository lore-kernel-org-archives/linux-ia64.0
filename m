From: "Stephens, Mike" <mike.stephens@intel.com>
Date: Wed, 19 Jul 2000 16:44:08 +0000
Subject: RE: [Linux-ia64] kernel modules
Message-Id: <marc-linux-ia64-105590678205215@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205210@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205210@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----Original Message-----
> From: Christian Groessler [mailto:cpg@aladdin.de]
> Sent: Wednesday, July 19, 2000 6:45 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] kernel modules
>
> Hi,
>
> I'm asking, whether loadable modules support is working and if not,
> what's still missing.
Yes modules can be made to work. However there are still a work in
progress, i.e. there are still bugs that need to be fix.

>
> I tried the current RH6.2 beta, and compiled the parport code
> as module. (which compiled after I copied include/asm-i386/parport.h
> to include/asm-ia64).
>
> But it crashed at load time. The crash seems to be happening at
> a function call itself, as a printk exactly before the call is
> displayed and a printk right at the beginning of the called
> function isn't. Seems like the module hasn't been linked
> correctly.
Unless you make changes to the Makefile they don't get linked correctly.
The current IA64 version modutils can't load a module if it (or the kernel)
was compiled with the -mconstant-gp flag, which is part of the CFLAGS define
in arch/ia64/Makefile.

Using a 2.4.0-test1 + 0609 patch (or newer kernel) and compile without the
constant-gp flag about 95% of the modules I have tried work. 

>
> I upgraded the kernel then to 2.4.0-test4, but no change.
>
> Then I upgraded modutils to 2.3.12, and now when I do lsmod
> it aborts with "get_kernel_syms: Function not implemented".
This is caused by a problems in the configure and makefile that
cause the modutils to get link wrong for IA64. The quick fix is
add USE_SYSCALL=n to the top of util/Makefile.

I hope to have a patch to fix this and a couple of other bugs
out some time this week.

>
> As far as I can tell, browsing thru the kernel code, there is
> a handler for this function and also in the sys_call_table.
> But I couldn't find the place where this error is generated.
>
> Any insights would be greatly appreciated.
>
> regards,
> chris


regards

Mike

_______________________
mike.stephens@intel.com



