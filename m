From: Max Filippov <jcmvbkbc@gmail.com>
Date: Wed, 24 Nov 2021 17:23:37 +0000
Subject: Re: [PATCH 1/1] futex: Wireup futex_waitv syscall
Message-Id: <CAMo8BfL18MQah-Bsf3NUUH+U5inLyErMfHoqr2vdwzUzCc=dyA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a3pQW59NVF=5P+ZiBjNJmnWh+iTZUHvqHBrXkHA6pMd4g@mail.gmail.com>
 <20211124132112.11641-1-andrealmeid@collabora.com>
In-Reply-To: <20211124132112.11641-1-andrealmeid@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Andr=C3=A9_Almeida?= <andrealmeid@collabora.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Michael Ellerman <mpe@ellerman.id.au>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "open list:IA64 (Itanium) PL..." <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, linuxppc-dev@lists.ozlabs.org, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPAR..." <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, boqun.feng@gmail.com, Linux-Next <linux-next@vger.kernel.org>, lkft-triage@lists.linaro.org, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, naresh.kamboju@linaro.org, Peter Zijlstra <peterz@infradead.org>, Rob Landley <rob@landley.net>, Sergey Senozhatsky <senozhatsky@chromium.org>, Stephen Rothwell <sfr@canb.auug.org.au>, umgwanakikbuti@gmail.com, Will Deacon <will@kernel.org>

On Wed, Nov 24, 2021 at 5:21 AM André Almeida <andrealmeid@collabora.com> wrote:
>
> Wireup futex_waitv syscall for all remaining archs.
>
> Signed-off-by: André Almeida <andrealmeid@collabora.com>
> ---
>  arch/alpha/kernel/syscalls/syscall.tbl      | 1 +
>  arch/ia64/kernel/syscalls/syscall.tbl       | 1 +
>  arch/m68k/kernel/syscalls/syscall.tbl       | 1 +
>  arch/microblaze/kernel/syscalls/syscall.tbl | 1 +
>  arch/powerpc/kernel/syscalls/syscall.tbl    | 1 +
>  arch/sh/kernel/syscalls/syscall.tbl         | 1 +
>  arch/sparc/kernel/syscalls/syscall.tbl      | 1 +
>  arch/xtensa/kernel/syscalls/syscall.tbl     | 1 +
>  8 files changed, 8 insertions(+)

For xtensa:
Acked-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max
