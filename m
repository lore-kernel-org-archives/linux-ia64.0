From: "Arnd Bergmann" <arnd@arndb.de>
Date: Tue, 09 May 2023 09:37:46 +0000
Subject: Re: [RFC PATCH] asm-generic: Unify uapi bitsperlong.h
Message-Id: <b9624545-2c80-49a1-ac3c-39264a591f7b@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1683615903-10862-1-git-send-email-yangtiezhu@loongson.cn>
In-Reply-To: <1683615903-10862-1-git-send-email-yangtiezhu@loongson.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tiezhu Yang <yangtiezhu@loongson.cn>
Cc: linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, bpf@vger.kernel.org, linux-perf-users@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, llvm@lists.linux.dev, linux-kernel@vger.kernel.org, loongson-kernel@lists.loongnix.cn

On Tue, May 9, 2023, at 09:05, Tiezhu Yang wrote:
> Now we specify the minimal version of GCC as 5.1 and Clang/LLVM as 11.0.0
> in Documentation/process/changes.rst, __CHAR_BIT__ and __SIZEOF_LONG__ are
> usable, just define __BITS_PER_LONG as (__CHAR_BIT__ * __SIZEOF_LONG__) in
> asm-generic uapi bitsperlong.h, simpler, works everywhere.
>
> Remove all the arch specific uapi bitsperlong.h which will be generated as
> arch/*/include/generated/uapi/asm/bitsperlong.h.
>
> Suggested-by: Xi Ruoyao <xry111@xry111.site>
> Link: 
> https://lore.kernel.org/all/d3e255e4746de44c9903c4433616d44ffcf18d1b.camel@xry111.site/
> Signed-off-by: Tiezhu Yang <yangtiezhu@loongson.cn>

I originally introduced the bitsperlong.h header, and I'd love to
see it removed if it's no longer needed. Your patch certainly
seems like it does this well.

There is one minor obstacle to this, which is that the compiler
requirements for uapi headers are not the same as for kernel
internal code. In particular, the uapi headers may be included
by user space code that is built with an older compiler version,
or with a compiler that is not gcc or clang.

I think we are completely safe on the architectures that were
added since the linux-3.x days (arm64, riscv, csky, openrisc,
loongarch, nios2, and hexagon), but for the older ones there
is a regression risk. Especially on targets that are not that
actively maintained (sparc, alpha, ia64, sh, ...) there is
a good chance that users are stuck on ancient toolchains.

It's probably also a safe assumption that anyone with an older
libc version won't be using the latest kernel headers, so
I think we can still do this across architectures if both
glibc and musl already require a compiler that is new enough,
or alternatively if we know that the kernel headers require
a new compiler for other reasons and nobody has complained.

For glibc, it looks the minimum compiler version was raised
from gcc-5 to gcc-8 four years ago, so we should be fine.

In musl, the documentation states that at least gcc-3.4 or
clang-3.2 are required, which probably predate the
__SIZEOF_LONG__ macro. On the other hand, musl was only
released in 2011, and building musl itself explicitly
does not require kernel uapi headers, so this may not
be too critical.

There is also uClibc, but I could not find any minimum
supported compiler version for that. Most commonly, this
one is used for cross-build environments, so it's also
less likely to have libc/gcc/headers being wildly out of
sync. Not sure.

      Arnd

[1] https://sourceware.org/pipermail/libc-alpha/2019-January/101010.html
