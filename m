From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 16 Apr 2012 07:21:58 +0000
Subject: Re: [PATCH] gpiolib/arches: Centralise bolierplate asm/gpio.h
Message-Id: <CACRpkdZ8yH1ZSG-nQ9dLm0TipHS-jZDuxwqohUC=LGH9V-5q4w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1334483574-3997-1-git-send-email-broonie@opensource.wolfsonmicro.com>
In-Reply-To: <1334483574-3997-1-git-send-email-broonie@opensource.wolfsonmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Grant Likely <grant@secretlab.ca>, Linus Walleij <linus.walleij@stericsson.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux@openrisc.net, "linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>, sparclinux@vger.kernel.org, Chris Zankel <chris@zankel.net>

On Sun, Apr 15, 2012 at 11:52 AM, Mark Brown
<broonie@opensource.wolfsonmicro.com> wrote:

> Rather than requiring architectures that use gpiolib but don't have any
> need to define anything custom to copy an asm/gpio.h provide a Kconfig
> symbol which architectures must select in order to include gpio.h and
> for other architectures just provide the trivial implementation directly.
>
> This makes it much easier to do gpiolib updates and is also a step towards
> making gpiolib APIs available on every architecture.
>
> For architectures with existing boilerplate code leave a stub header in
> place which warns on direct inclusion of asm/gpio.h and includes
> linux/gpio.h to catch code that's doing this. =A0Direct inclusion of
> asm/gpio.h has long been deprecated.
>
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
> ---
> =A0arch/alpha/include/asm/gpio.h =A0 =A0 =A0| =A0 59 ++------------------=
----------
> =A0arch/arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/avr32/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/blackfin/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0arch/ia64/include/asm/gpio.h =A0 =A0 =A0 | =A0 59 ++------------------=
----------
> =A0arch/m68k/Kconfig.cpu =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0arch/microblaze/include/asm/gpio.h | =A0 57 ++------------------------=
---
> =A0arch/mips/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0arch/openrisc/include/asm/gpio.h =A0 | =A0 69 ++----------------------=
-----------
> =A0arch/powerpc/include/asm/gpio.h =A0 =A0| =A0 57 ++--------------------=
-------
> =A0arch/sh/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0arch/sparc/include/asm/gpio.h =A0 =A0 =A0| =A0 40 ++-------------------
> =A0arch/unicore32/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/x86/include/asm/gpio.h =A0 =A0 =A0 =A0| =A0 57 ++----------------=
-----------
> =A0arch/xtensa/include/asm/gpio.h =A0 =A0 | =A0 60 ++--------------------=
---------
> =A0drivers/gpio/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08 ++++
> =A0include/linux/gpio.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 34 ++++++++++++=
+++++
> =A017 files changed, 81 insertions(+), 426 deletions(-)

This looks good but I think we need to page the alpha, ia64, m68k, microbla=
ze,
openrisc etc subarch maintainers on this patch so they have their say.

Yours,
Linus Walleij
