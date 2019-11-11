From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 11 Nov 2019 18:08:51 +0000
Subject: Re: [PATCH v2 11/29] vmlinux.lds.h: Replace RODATA with RO_DATA
Message-Id: <CAMuHMdUJ8QPvqf51nVmOg1Zm20SNT7pXR72z=qmco=ecwawZ7A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org> <20191011000609.29728-12-keescook@chromium.org>
 <CAMuHMdXfPyti1wFBb0hhf3CeDSQ=zVv7cV-taeYCmDswMQkXPQ@mail.gmail.com> <201911110922.17A2112B0@keescook>
In-Reply-To: <201911110922.17A2112B0@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Borislav Petkov <bp@alien8.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, Will Deacon <will@kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, alpha <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, Parisc List <linux-parisc@vger.kernel.org>, linux-xtensa@linux-xtensa.org, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Kees,

On Mon, Nov 11, 2019 at 6:23 PM Kees Cook <keescook@chromium.org> wrote:
> On Mon, Nov 11, 2019 at 05:58:06PM +0100, Geert Uytterhoeven wrote:
> > On Fri, Oct 11, 2019 at 2:07 AM Kees Cook <keescook@chromium.org> wrote:
> > > There's no reason to keep the RODATA macro: replace the callers with
> > > the expected RO_DATA macro.
> > >
> > > Signed-off-by: Kees Cook <keescook@chromium.org>
> > > ---
> > >  arch/alpha/kernel/vmlinux.lds.S      | 2 +-
> > >  arch/ia64/kernel/vmlinux.lds.S       | 2 +-
> > >  arch/microblaze/kernel/vmlinux.lds.S | 2 +-
> > >  arch/mips/kernel/vmlinux.lds.S       | 2 +-
> > >  arch/um/include/asm/common.lds.S     | 2 +-
> > >  arch/xtensa/kernel/vmlinux.lds.S     | 2 +-
> > >  include/asm-generic/vmlinux.lds.h    | 4 +---
> > >  7 files changed, 7 insertions(+), 9 deletions(-)
> >
> > Somehow you missed:
> >
> >     arch/m68k/kernel/vmlinux-std.lds:  RODATA
> >     arch/m68k/kernel/vmlinux-sun3.lds:      RODATA
>
> Argh. I've sent a patch; sorry and thanks for catching this. For my own
> cross-build testing, which defconfig targets will hit these two linker
> scripts?

vmlinux-sun3.lds: sun3_defconfig
vmlinux-std.lds: All other classic 680x0 targets with an MMU, e.g. plain
                 defconfig aka multi_defconfig.

> > Leading to build failures in next-20191111:
> >
> >     /opt/cross/kisskb/gcc-4.6.3-nolibc/m68k-linux/bin/m68k-linux-ld:./arch/m68k/kernel/vmlinux.lds:29:
> > syntax error
> >     make[1]: *** [/kisskb/src/Makefile:1075: vmlinux] Error 1
> >
> > Reported-by: noreply@ellerman.id.au
> > http://kisskb.ellerman.id.au/kisskb/buildresult/14022846/

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
