From: Dave Hansen <dave.hansen@intel.com>
Date: Tue, 11 Oct 2022 15:31:04 +0000
Subject: Re: [RFC PATCH] Remove Intel compiler support
Message-Id: <3b5bfa95-ff64-0e8b-44a3-8b67b767ffd6@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221011031843.960217-1-masahiroy@kernel.org>
In-Reply-To: <20221011031843.960217-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, Nick Desaulniers <ndesaulniers@google.com>, Miguel Ojeda <ojeda@kernel.org>, Len Brown <lenb@kernel.org>, Nathan Chancellor <nathan@kernel.org>, Nick Terrell <terrelln@fb.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Robert Moore <robert.moore@intel.com>, Tom Rix <trix@redhat.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev

On 10/10/22 20:18, Masahiro Yamada wrote:
> I am sending this to Linus and the x86 maintainers with RFC.
> If somebody is still using ICC, please speak up!

Yeah, the bit rot is not a good sign.  I honestly can't remember seeing
anyone actually use icc during my entire tenure at Intel.  I'll ask
around to see if there's any plausible reason to fix this up and keep
it.  But, I'm not holding my breath.
