From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 19 Aug 2020 08:45:47 +0000
Subject: Re: [PATCH 04/11] m68k: switch to kernel_clone()
Message-Id: <CAMuHMdUPtAT_b72WT_SYWr-M7uq=RucgnbJghTUj+YU8PVdcYQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200818173411.404104-1-christian.brauner@ubuntu.com> <20200818173411.404104-5-christian.brauner@ubuntu.com>
In-Reply-To: <20200818173411.404104-5-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Christoph Hewllig <hch@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Arch <linux-arch@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ley Foon Tan <ley.foon.tan@intel.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, Stafford Horne <shorne@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Kars de Jong <jongk@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Greentime Hu <green.hu@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Mauro Carvalho Chehab <mchehab+huawei@kernel.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, Masami Hiramatsu <mhiramat@kernel.org>, Tom Zanussi <zanussi@kernel.org>, Xiao Yang <yangx.jy@cn.fujitsu.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, sparclinux <sparclinux@vger.kernel.org>, kgdb-bugreport@lists.sourceforge.net, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>

On Tue, Aug 18, 2020 at 7:37 PM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
> The old _do_fork() helper is removed in favor of the new kernel_clone() helper.
> The latter adheres to naming conventions for kernel internal syscall helpers.
>
> Cc: Kars de Jong <jongk@linux-m68k.org>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: linux-m68k@lists.linux-m68k.org
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
