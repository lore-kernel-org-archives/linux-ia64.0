From: "Christian Groessler" <cpg@aladdin.de>
Date: Wed, 19 Jul 2000 13:45:29 +0000
Subject: [Linux-ia64] kernel modules
Message-Id: <marc-linux-ia64-105590678205210@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Hi,

I'm asking, whether loadable modules support is working and if not,
what's still missing.

I tried the current RH6.2 beta, and compiled the parport code
as module. (which compiled after I copied include/asm-i386/parport.h
to include/asm-ia64).

But it crashed at load time. The crash seems to be happening at
a function call itself, as a printk exactly before the call is
displayed and a printk right at the beginning of the called
function isn't. Seems like the module hasn't been linked
correctly.

I upgraded the kernel then to 2.4.0-test4, but no change.

Then I upgraded modutils to 2.3.12, and now when I do lsmod
it aborts with "get_kernel_syms: Function not implemented".

As far as I can tell, browsing thru the kernel code, there is
a handler for this function and also in the sys_call_table.
But I couldn't find the place where this error is generated.

Any insights would be greatly appreciated.

regards,
chris




