From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 10 May 2021 13:12:09 +0000
Subject: Re: [RFC 01/12] asm-generic: use asm-generic/unaligned.h for most architectures
Message-Id: <CAK8P3a15W5vV9ivk6YnR2aGMvDjTrPGrzsszf2kD6kv1TfrpbQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210507220813.365382-1-arnd@kernel.org> <20210507220813.365382-2-arnd@kernel.org>
 <CAMuHMdV1=mJzbr1cLwo-zUnThh9J8BmdW870dJCvp_Kft8kM2w@mail.gmail.com>
In-Reply-To: <CAMuHMdV1=mJzbr1cLwo-zUnThh9J8BmdW870dJCvp_Kft8kM2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vineet Gupta <vgupta@synopsys.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michal Simek <monstr@monstr.eu>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, alpha <linux-alpha@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Parisc List <linux-parisc@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

On Mon, May 10, 2021 at 12:16 PM Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> On Sat, May 8, 2021 at 12:09 AM Arnd Bergmann <arnd@kernel.org> wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> >
> > There are several architectures that just duplicate the contents
> > of asm-generic/unaligned.h, so change those over to use the
> > file directly, to make future modifications easier.
> >
> > The exceptions are:
> >
> > - arm32 sets HAVE_EFFICIENT_UNALIGNED_ACCESS, but wants the
> >   unaligned-struct version
> >
> > - ppc64le disables HAVE_EFFICIENT_UNALIGNED_ACCESS but includes
> >   the access-ok version
> >
> > - m68k (non-dragonball) also uses the access-ok version without
> >   setting HAVE_EFFICIENT_UNALIGNED_ACCESS.
>
> This not only applies to dragonball, which has the CPU32 core, but also
> to plain 68000, and any SoCs including the 68EC000 core.

I meant out of the machines that are currently supported in the kernel.
As far as I can tell, the only 68000 variants that are supported are
all Dragonball CONFIG_M68328, CONFIG_M68EZ328 and
CONFIG_M68VZ328.

CONFIG_MCPU32 has been dead since a3595962d824 ("m68knommu:
remove obsolete 68360 support")

> Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Thanks!

        Arnd
