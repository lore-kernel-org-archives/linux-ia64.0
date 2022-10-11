From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 11 Oct 2022 03:45:47 +0000
Subject: Re: [RFC PATCH] Remove Intel compiler support
Message-Id: <CAHk-=wjP4=XP6E30mRp3OP2swZOrML9Z78kJvKo8ejFi4WGZjw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221011031843.960217-1-masahiroy@kernel.org>
In-Reply-To: <20221011031843.960217-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, Nick Desaulniers <ndesaulniers@google.com>, Miguel Ojeda <ojeda@kernel.org>, Len Brown <lenb@kernel.org>, Nathan Chancellor <nathan@kernel.org>, Nick Terrell <terrelln@fb.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Robert Moore <robert.moore@intel.com>, Tom Rix <trix@redhat.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev

On Mon, Oct 10, 2022 at 8:19 PM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
> I am sending this to Linus and the x86 maintainers with RFC.
> If somebody is still using ICC, please speak up!

Ack. I don't think anybody ever really used icc.

I can't recall having heard a single peep about icc problems, and I
don't think it's because it was *so* good at emulating gcc that nobody
ever hit any issues.

               Linus
