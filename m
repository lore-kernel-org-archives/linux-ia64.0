From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 12 Nov 2019 09:13:53 +0000
Subject: Re: [PATCH v2 11/29] vmlinux.lds.h: Replace RODATA with RO_DATA
Message-Id: <CAMuHMdXayF+z4z+Ds-gm4+YFA=BCMo0_9Q3uXcbQQgQkLxZ4uw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org> <20191011000609.29728-12-keescook@chromium.org>
 <CAMuHMdXfPyti1wFBb0hhf3CeDSQ=zVv7cV-taeYCmDswMQkXPQ@mail.gmail.com>
 <201911110922.17A2112B0@keescook> <CAMuHMdUJ8QPvqf51nVmOg1Zm20SNT7pXR72z=qmco=ecwawZ7A@mail.gmail.com>
 <20191112090736.GA32336@zn.tnic>
In-Reply-To: <20191112090736.GA32336@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Borislav Petkov <bp@alien8.de>
Cc: Kees Cook <keescook@chromium.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, Will Deacon <will@kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, alpha <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, Parisc List <linux-parisc@vger.kernel.org>, linux-xtensa@linux-xtensa.org, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Borislav,

On Tue, Nov 12, 2019 at 10:08 AM Borislav Petkov <bp@alien8.de> wrote:
> On Mon, Nov 11, 2019 at 07:08:51PM +0100, Geert Uytterhoeven wrote:
> > vmlinux-std.lds: All other classic 680x0 targets with an MMU, e.g. plain
> >                  defconfig aka multi_defconfig.
>
> FWIW, the defconfig doesn't build with the cross compiler=C2=B9 here, eve=
n with Kees'
> patch applied but for a different reason:
>
> $ make.cross ARCH=3Dm68k defconfig
> ...
>
> $make.cross ARCH=3Dm68k 2>w.log
> ...
> drivers/video/fbdev/c2p_planar.o: In function `transp8':
> c2p_planar.c:(.text+0x13a): undefined reference to `c2p_unsupported'
> c2p_planar.c:(.text+0x1de): undefined reference to `c2p_unsupported'
> drivers/video/fbdev/c2p_iplan2.o: In function `transp4x.constprop.0':
> c2p_iplan2.c:(.text+0x98): undefined reference to `c2p_unsupported'
> make: *** [Makefile:1094: vmlinux] Error 1

The fix for that regression (finally) made it in rc7:
b330f3972f4f2a82 ("fbdev: c2p: Fix link failure on non-inlining").

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
