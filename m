From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 18 Dec 2020 15:55:50 +0000
Subject: Re: [PATCH 01/23] kernel: irq: irqdescs: warn on spurious IRQ
Message-Id: <CAHp75VfYz_K2BYOxqmSx0q+1F2F9Lp1eb70RrNYzJHs3FX+quQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201218143122.19459-1-info@metux.net> <20201218143122.19459-2-info@metux.net>
In-Reply-To: <20201218143122.19459-2-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, msalter@redhat.com, jacquiot.aurelien@gmail.com, gerg@linux-m68k.org, Geert Uytterhoeven <geert@linux-m68k.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, James Bottomley <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Linus Walleij <linus.walleij@linaro.org>, Bartosz Golaszewski <bgolaszewski@baylibre.com>, Marc Zyngier <maz@kernel.org>, Tony Lindgren <tony@atomide.com>, Arnd Bergmann <arnd@arndb.de>, linux-alpha@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT" <linuxppc-dev@lists.ozlabs.org>, linux-s390@vger.kernel.org, Linux-SH <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, Linux OMAP Mailing List <linux-omap@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>

On Fri, Dec 18, 2020 at 4:37 PM Enrico Weigelt, metux IT consult
<info@metux.net> wrote:

> +               if (printk_ratelimit())
> +                       pr_warn("spurious IRQ: irq=%d hwirq=%d nr_irqs=%d\n",
> +                               irq, hwirq, nr_irqs);

Perhaps you missed pr_warn_ratelimit() macro which is already in the
kernel for a long time.

-- 
With Best Regards,
Andy Shevchenko
