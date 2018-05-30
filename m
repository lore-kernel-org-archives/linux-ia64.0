From: Rob Landley <rob@landley.net>
Date: Wed, 30 May 2018 22:36:45 +0000
Subject: Re: [PATCH] kbuild: add machine size to CHEKCFLAGS
Message-Id: <0dd9d6dc-6cb3-157c-33ac-8c3e449a3859@landley.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180530204838.22079-1-luc.vanoostenryck@gmail.com>
 <d47b72cc-9209-a190-38b3-969870e1bf26@suse.de>
In-Reply-To: <d47b72cc-9209-a190-38b3-969870e1bf26@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Brendan Higgins <brendanhiggins@google.com>

On 05/30/2018 05:00 PM, Andreas F=C3=A4rber wrote:
> What about the architectures not touched by your patch that previously
> had no -m32/-m64? (arc, c6x, h8300, hexagon, m68k, microblaze, nds32,
> nios2, openrisc, powerpc, riscv, s390, sh, unicore32, xtensa)
>=20
> You forgot to CC them on this patch.

A) He cc'd arch/sh on the previous patch earlier today, to which I replied:

https://marc.info/?l=3Dlinux-sh&m=152769132515226&w=3D2

B) Every change to common infrastructure should cc: every arch? Really? So =
like
filesystem changes and stuff to?

> Have you really checked that all their toolchains support the -m32/-m64
> flags you newly introduce for them? Apart from non-biarch architectures,
> I'm thinking of 31-bit s390 as a corner case where !64 !=3D 32.

1) Last I heard Linux implements lp64:
   http://www.unix.org/whitepapers/64bit.html

2) it's unlikely to be worse than it was before the patch,

3) last I checked https://github.com/landley/mkroot boots to an s390 shell
prompt under qemu, although I haven't tried building with this patch. (And =
you
may still need to add HOST_EXTRA=3D'lex yacc bison flex' to the command line
unless they've re-added the _shipped versions like the old kconfig had...) =
Point
is, shouldn't be too hard to test it. Presumably that's why we have an -rc1=
 and
then 6 more -rc versions each release...

Rob
