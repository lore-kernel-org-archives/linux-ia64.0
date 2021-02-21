From: Masahiro Yamada <masahiroy@kernel.org>
Date: Sun, 21 Feb 2021 17:14:47 +0000
Subject: Re: [PATCH 1/2] arch: syscalls: add missing FORCE and fix 'targets' to make if_changed work
Message-Id: <CAK7LNATvCAyHSUQNTdSck3JM1MfHNFcanjn0i4835okWE9Km5w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210215004823.440102-1-masahiroy@kernel.org>
In-Reply-To: <20210215004823.440102-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, X86 ML <x86@kernel.org>

On Mon, Feb 15, 2021 at 9:50 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
> The rules in these Makefiles cannot detect the command line change
> because the prerequisite 'FORCE' is missing.
>
> Adding 'FORCE' will result in the headers being rebuilt every time
> because the 'targets' additions are also wrong; the file paths in
> 'targets' must be relative to the current Makefile.
>
> Fix all of them so the if_changed rules work correctly.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>


Both applied to linux-kbuild.


-- 
Best Regards
Masahiro Yamada
