From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 31 Mar 2012 16:40:30 +0000
Subject: Re: [PATCH RFC] Simplify the Linux kernel by reducing its state space
Message-Id: <CAMuHMdWTB+_AtqM6JixY=Oo_zmzX_dNxnivpARBYSbPJzp4t6A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120331163321.GA15809@linux.vnet.ibm.com>
In-Reply-To: <20120331163321.GA15809@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-arm-kernel@lists.infradead.org

Hi Paul,

On Sat, Mar 31, 2012 at 18:33, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> Although there have been numerous complaints about the complexity of
> parallel programming (especially over the past 5-10 years), the plain
> truth is that the incremental complexity of parallel programming over
> that of sequential programming is not as large as is commonly believed.
> Despite that you might have heard, the mind-numbing complexity of modern
> computer systems is not due so much to there being multiple CPUs, but
> rather to there being any CPUs at all.  In short, for the ultimate in
> computer-system simplicity, the optimal choice is NR_CPUS=0.
>
> This commit therefore limits kernel builds to zero CPUs.  This change
> has the beneficial side effect of rendering all kernel bugs harmless.
> Furthermore, this commit enables additional beneficial changes, for
> example, the removal of those parts of the kernel that are not needed
> when there are zero CPUs.
>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>
>  alpha/Kconfig                     |   11 ++++++-----
>  arm/Kconfig                       |    6 +++---
>  blackfin/Kconfig                  |    3 ++-
>  hexagon/Kconfig                   |    9 +++++----
>  ia64/Kconfig                      |    9 +++++----
>  m32r/Kconfig                      |   10 ++++++----
>  mips/Kconfig                      |   21 +++++++++++----------
>  mn10300/Kconfig                   |    3 ++-
>  parisc/Kconfig                    |    6 +++---
>  powerpc/platforms/Kconfig.cputype |    8 ++++----
>  s390/Kconfig                      |   12 +++++++-----
>  sh/Kconfig                        |   11 ++++++-----
>  sparc/Kconfig                     |    8 ++++----
>  tile/Kconfig                      |    9 +++++----
>  x86/Kconfig                       |   16 +++++++++-------
>  15 files changed, 78 insertions(+), 64 deletions(-)

You forgot to fix half of the architectures, a.o. m68k?

Gr{oetje,eeting}s,

                        Geert (still at GMT+2)

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
