From: "Arnd Bergmann" <arnd@arndb.de>
Date: Tue, 11 Oct 2022 15:18:10 +0000
Subject: Re: [RFC PATCH] Remove Intel compiler support
Message-Id: <08db7754-ecd8-4425-875b-4f2b44497f6b@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221011031843.960217-1-masahiroy@kernel.org>
In-Reply-To: <20221011031843.960217-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, Nick Desaulniers <ndesaulniers@google.com>, Miguel Ojeda <ojeda@kernel.org>, Len Brown <lenb@kernel.org>, Nathan Chancellor <nathan@kernel.org>, Nick Terrell <terrelln@fb.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Robert Moore <robert.moore@intel.com>, Tom Rix <trix@redhat.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev

On Tue, Oct 11, 2022, at 5:18 AM, Masahiro Yamada wrote:
> include/linux/compiler-intel.h had no update in the past 3 years.
>
> We often forget about the third C compiler to build the kernel.
>
> For example, commit a0a12c3ed057 ("asm goto: eradicate CC_HAS_ASM_GOTO")
> only mentioned GCC and Clang.
>
> init/Kconfig defines CC_IS_GCC and CC_IS_CLANG but not CC_IS_ICC,
> and nobody has reported any issue.
>
> I guess the Intel Compiler support is broken, and nobody is caring
> about it.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
> ---
>
> I am sending this to Linus and the x86 maintainers with RFC.
> If somebody is still using ICC, please speak up!

Acked-by: Arnd Bergmann <arnd@arndb.de>


I had the same thought a while back and tried to show that it as
already broken, but I never managed to actually download the compiler
at the time.

It appears that in the meantime, Intel have completely dropped their
old codebase and moved to using LLVM[1], so my guess is that with the
current releases it will behave the same as clang. It might help
to verify that this is indeed the case if you want to add that
to the changelog text.

     Arnd

[1] https://www.intel.com/content/www/us/en/developer/articles/technical/adoption-of-llvm-complete-icx.html
