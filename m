From: Masahiro Yamada <masahiroy@kernel.org>
Date: Tue, 11 Oct 2022 16:57:36 +0000
Subject: Re: [RFC PATCH] Remove Intel compiler support
Message-Id: <CAK7LNAS3VMaZ2epwRuZt3dKCH434iKmrVnzBNxZ1ktbeTUaWWw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221011031843.960217-1-masahiroy@kernel.org> <CANiq72k9wAVCbHKVZFE=E3xv+2ZamUMsJ=uV43NxsSUQ4wXGdw@mail.gmail.com>
 <CAK7LNASP74qJ5fjjcVYcw4CyZ1psPnnyzLHsUu0b+MxLq-W1eQ@mail.gmail.com>
In-Reply-To: <CAK7LNASP74qJ5fjjcVYcw4CyZ1psPnnyzLHsUu0b+MxLq-W1eQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, Nick Desaulniers <ndesaulniers@google.com>, Miguel Ojeda <ojeda@kernel.org>, Len Brown <lenb@kernel.org>, Nathan Chancellor <nathan@kernel.org>, Nick Terrell <terrelln@fb.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Robert Moore <robert.moore@intel.com>, Tom Rix <trix@redhat.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev

On Wed, Oct 12, 2022 at 1:52 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
> On Tue, Oct 11, 2022 at 8:55 PM Miguel Ojeda
> <miguel.ojeda.sandonis@gmail.com> wrote:
> >
> > On Tue, Oct 11, 2022 at 5:19 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
> > >
> > >  include/linux/compiler-intel.h            |  34 -----
> > >  include/linux/compiler_types.h            |   2 -
> >
> > You can also remove a few lines from `compiler_attributes.h`:
> >
> >     * Optional: not supported by icc
> >
> > Thanks for this!
> >
> > Cheers,
> > Miguel
>
>
>
> Thanks.
>
>
> Maybe, we can drop #if ... #else ... #endif
> around __assume_aligned(a, ...), but I will leave it to you.
>
>
> I will just drop the comment lines for now.
> (Then, you will clean up compiler_attributes.h in the next cycle)
> Is this your expectation for v2 ?


Taking a look at the code, there is only one redundant #if.
So, I will clean up __assume_aligned() in v2.








-- 
Best Regards
Masahiro Yamada
