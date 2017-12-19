From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 19 Dec 2017 11:49:24 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <CAMuHMdV3x6jqWj3S=U-rK4HB9oYSEO1fES0bKWjouu7QqapF3w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de>
In-Reply-To: <20171219114112.939391-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, Vineet Gupta <vgupta@synopsys.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, arcml <linux-snps-arc@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Cris <linux-cris-kernel@axis.com>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-sparse@vger.kernel.org

Hi Arnd,

On Tue, Dec 19, 2017 at 12:39 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> The name barrier_before_unreachable() is a bit suboptimal here,
> as it fails to describe the fact that it is needed for both
> __builtin_unreachable() and for calling noreturn functions.  Any other
> suggestions would be welcome here.

/me joins bikeshedding...

barrier_before_noreturn()?
barrier_before_dead_end()?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
