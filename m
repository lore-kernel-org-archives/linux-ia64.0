From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 12 Feb 2020 09:25:57 +0000
Subject: Re: [PATCH v2] asm-generic: Fix unistd_32.h generation format
Message-Id: <CAMuHMdUZ_e9JsF0fuLxBwdoy7YVLarH6E98z5nKUZ2CccSkV-Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <dcdd615f77dacf8a98e18950b66fb5a675277f38.1581498987.git.michal.simek@xilinx.com>
 <CAMo8BfLYM-_SbqmMUCVjwqL7MpA2W7toTg_F6HTY4Sg5QxGzfw@mail.gmail.com>
In-Reply-To: <CAMo8BfLYM-_SbqmMUCVjwqL7MpA2W7toTg_F6HTY4Sg5QxGzfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: Michal Simek <michal.simek@xilinx.com>, LKML <linux-kernel@vger.kernel.org>, Michal Simek <monstr@monstr.eu>, git@xilinx.com, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Stefan Asserhall <stefan.asserhall@xilinx.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Matt Turner <mattst88@gmail.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "open list:IA64 (Itanium) PL..." <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, "open list:SPARC + UltraSPAR..." <sparclinux@vger.kernel.org>

Hi Max,

On Wed, Feb 12, 2020 at 10:23 AM Max Filippov <jcmvbkbc@gmail.com> wrote:
> On Wed, Feb 12, 2020 at 1:16 AM Michal Simek <michal.simek@xilinx.com> wrote:
> >
> > Generated files are also checked by sparse that's why add newline
> > to remove sparse (C=1) warning.
> >
> > The issue was found on Microblaze and reported like this:
> > ./arch/microblaze/include/generated/uapi/asm/unistd_32.h:438:45:
> > warning: no newline at end of file
> >
> > Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> > Reviewed-by: Stefan Asserhall <stefan.asserhall@xilinx.com>

> > --- a/arch/m68k/kernel/syscalls/syscallhdr.sh
> > +++ b/arch/m68k/kernel/syscalls/syscallhdr.sh
> > @@ -33,4 +33,5 @@ grep -E "^[0-9A-Fa-fXx]+[[:space:]]+${my_abis}" "$in" | sort -n | (
> >         printf "#endif\n"
> >         printf "\n"
> >         printf "#endif /* %s */\n" "${fileguard}"
>
> Here there's already \n at the end, so no need for another one?

Thanks! I completely missed that.
So I did fix the original while applying ;-)

> > +       printf "\n"
> >  ) > "$out"

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
