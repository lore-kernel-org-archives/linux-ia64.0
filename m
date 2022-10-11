From: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Date: Tue, 11 Oct 2022 11:55:39 +0000
Subject: Re: [RFC PATCH] Remove Intel compiler support
Message-Id: <CANiq72k9wAVCbHKVZFE=E3xv+2ZamUMsJ=uV43NxsSUQ4wXGdw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221011031843.960217-1-masahiroy@kernel.org>
In-Reply-To: <20221011031843.960217-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, Nick Desaulniers <ndesaulniers@google.com>, Miguel Ojeda <ojeda@kernel.org>, Len Brown <lenb@kernel.org>, Nathan Chancellor <nathan@kernel.org>, Nick Terrell <terrelln@fb.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Robert Moore <robert.moore@intel.com>, Tom Rix <trix@redhat.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev

On Tue, Oct 11, 2022 at 5:19 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
>  include/linux/compiler-intel.h            |  34 -----
>  include/linux/compiler_types.h            |   2 -

You can also remove a few lines from `compiler_attributes.h`:

    * Optional: not supported by icc

Thanks for this!

Cheers,
Miguel
