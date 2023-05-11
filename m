From: Nhat Pham <nphamcs@gmail.com>
Date: Thu, 11 May 2023 19:34:23 +0000
Subject: Re: [PATCH] cachestat: wire up cachestat for other architectures
Message-Id: <CAKEwX=OHMaUzEG9hoMz20m9DnyFD4xC78KiNV1Qu0bUhkrYhAA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510195806.2902878-1-nphamcs@gmail.com> <874joja6vz.fsf@mail.lhotse>
In-Reply-To: <874joja6vz.fsf@mail.lhotse>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-api@vger.kernel.org, kernel-team@meta.com, linux-arch@vger.kernel.org, hannes@cmpxchg.org, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux@armlinux.org.uk, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com, deller@gmx.de, npiggin@gmail.com, christophe.leroy@csgroup.eu, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, glaubitz@physik.fu-berlin.de, davem@davemloft.net, chris@zankel.net, jcmvbkbc@gmail.com, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Wed, May 10, 2023 at 8:23=E2=80=AFPM Michael Ellerman <mpe@ellerman.id.a=
u> wrote:
>
> Nhat Pham <nphamcs@gmail.com> writes:
> > cachestat is previously only wired in for x86 (and architectures using
> > the generic unistd.h table):
> >
> > https://lore.kernel.org/lkml/20230503013608.2431726-1-nphamcs@gmail.com/
> >
> > This patch wires cachestat in for all the other architectures.
> >
> > Signed-off-by: Nhat Pham <nphamcs@gmail.com>
> > ---
> >  arch/alpha/kernel/syscalls/syscall.tbl      | 1 +
> >  arch/arm/tools/syscall.tbl                  | 1 +
> >  arch/ia64/kernel/syscalls/syscall.tbl       | 1 +
> >  arch/m68k/kernel/syscalls/syscall.tbl       | 1 +
> >  arch/microblaze/kernel/syscalls/syscall.tbl | 1 +
> >  arch/mips/kernel/syscalls/syscall_n32.tbl   | 1 +
> >  arch/mips/kernel/syscalls/syscall_n64.tbl   | 1 +
> >  arch/mips/kernel/syscalls/syscall_o32.tbl   | 1 +
> >  arch/parisc/kernel/syscalls/syscall.tbl     | 1 +
> >  arch/powerpc/kernel/syscalls/syscall.tbl    | 1 +
>
> With the change to the selftest (see my other mail), I tested this on
> powerpc and all tests pass.

Saw the change you proposed, Michael! It looks good to me.
Thanks for helping me make the selftest suite more robust :)

>
> Tested-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
>
>
> cheers
