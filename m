From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 24 Nov 2021 13:49:53 +0000
Subject: Re: [PATCH 1/1] futex: Wireup futex_waitv syscall
Message-Id: <CAMuHMdViovyQ2xBeKaMRbAmYF5eMWKdYhQEPmnTyLJoF7a+xsg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a3pQW59NVF=5P+ZiBjNJmnWh+iTZUHvqHBrXkHA6pMd4g@mail.gmail.com>
 <20211124132112.11641-1-andrealmeid@collabora.com>
In-Reply-To: <20211124132112.11641-1-andrealmeid@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Andr=C3=A9_Almeida?= <andrealmeid@collabora.com>
Cc: Rich Felker <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, lkft-triage@lists.linaro.org, Max Filippov <jcmvbkbc@gmail.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, sparclinux <sparclinux@vger.kernel.org>, Will Deacon <will@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Yoshinori Sato <ysato@users.sourceforge.jp>, Sergey Senozhatsky <senozhatsky@chromium.org>, Naresh Kamboju <naresh.kamboju@linaro.org>, Linux-Next <linux-next@vger.kernel.org>, Waiman Long <longman@redhat.com>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Arnd Bergmann <arnd@arndb.de>, Boqun Feng <boqun.feng@gmail.com>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Ingo Molnar <mingo@redhat.com>, Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Rob Landley <rob@landley.net>, alpha <linux-alpha@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On Wed, Nov 24, 2021 at 2:21 PM André Almeida <andrealmeid@collabora.com> wrote:
> Wireup futex_waitv syscall for all remaining archs.
>
> Signed-off-by: André Almeida <andrealmeid@collabora.com>

>  arch/m68k/kernel/syscalls/syscall.tbl       | 1 +

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
