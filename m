From: "Christian Groessler" <cpg@aladdin.de>
Date: Fri, 21 Jul 2000 15:08:58 +0000
Subject: RE: [Linux-ia64] kernel modules
Message-Id: <marc-linux-ia64-105590678205220@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205210@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205210@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Hi,

On 07/19/2000 04:44:08 PM GMT "Stephens, Mike" wrote:
>
>> But it crashed at load time. The crash seems to be happening at
>> a function call itself, as a printk exactly before the call is
>> displayed and a printk right at the beginning of the called
>> function isn't. Seems like the module hasn't been linked
>> correctly.
>Unless you make changes to the Makefile they don't get linked correctly.
>The current IA64 version modutils can't load a module if it (or the
kernel)
>was compiled with the -mconstant-gp flag, which is part of the CFLAGS
define
>in arch/ia64/Makefile.
>
>Using a 2.4.0-test1 + 0609 patch (or newer kernel) and compile without the
>constant-gp flag about 95% of the modules I have tried work.

Thanks. When compiling w/o constant-gp the parport modules work, but...

>>
>> Then I upgraded modutils to 2.3.12, and now when I do lsmod
>> it aborts with "get_kernel_syms: Function not implemented".
>This is caused by a problems in the configure and makefile that
>cause the modutils to get link wrong for IA64. The quick fix is
>add USE_SYSCALL=n to the top of util/Makefile.

Regardless of USE_SYSCALL=n is there or not, I get the "Function
not implemeted" error with modutils-2.3.12.
I reverted to using the (precompiled) modutils which came on
the RedHat CD...

regards,
chris




