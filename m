From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 24 Nov 2021 23:18:00 +0000
Subject: Re: [PATCH 1/1] futex: Wireup futex_waitv syscall
Message-Id: <87v90hjg7r.ffs@tglx>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a3pQW59NVF=5P+ZiBjNJmnWh+iTZUHvqHBrXkHA6pMd4g@mail.gmail.com>
 <20211124132112.11641-1-andrealmeid@collabora.com>
 <CAK8P3a2BXefTw68yoZ9U0F=ASC3=EZDc5PDQCJ16MmXtynd59g@mail.gmail.com>
In-Reply-To: <CAK8P3a2BXefTw68yoZ9U0F=ASC3=EZDc5PDQCJ16MmXtynd59g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Arnd Bergmann <arnd@arndb.de>, =?utf-8?Q?Andr=C3=A9?= Almeida <andrealmeid@collabora.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Michael Ellerman <mpe@ellerman.id.au>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, David Miller <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, alpha <linux-alpha@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Boqun Feng <boqun.feng@gmail.com>, Linux-Next Mailing List <linux-next@vger.kernel.org>, lkft-triage@lists.linaro.org, Waiman Long <longman@redhat.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Naresh Kamboju <naresh.kamboju@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Rob Landley <rob@landley.net>, Sergey Senozhatsky <senozhatsky@chromium.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Mike Galbraith <umgwanakikbuti@gmail.com>, Will Deacon <will@kernel.org>

On Wed, Nov 24 2021 at 15:29, Arnd Bergmann wrote:
> On Wed, Nov 24, 2021 at 2:21 PM André Almeida <andrealmeid@collabora.com> wrote:
>>
>> Wireup futex_waitv syscall for all remaining archs.
>>
>> Signed-off-by: André Almeida <andrealmeid@collabora.com>
>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
>
> I double-checked that futex_waitv() doesn't need any architecture specific
> hacks, and that the list above is complete.
>
> Should I take this through the asm-generic tree, or would you send it
> through the tip tree?

Feel free to pick it up.

Thanks,

        tglx
