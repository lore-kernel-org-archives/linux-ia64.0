From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 16 Apr 2012 08:26:02 +0000
Subject: Re: [PATCH] gpiolib/arches: Centralise bolierplate asm/gpio.h
Message-Id: <CACRpkdb8q4bKSBctBV0V5KrbS-r-P_b_+N75UV58ryxK+jz+8A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1334483574-3997-1-git-send-email-broonie@opensource.wolfsonmicro.com>
	<CACRpkdZ8yH1ZSG-nQ9dLm0TipHS-jZDuxwqohUC=LGH9V-5q4w@mail.gmail.com>
	<20120416081532.GA3238@opensource.wolfsonmicro.com>
In-Reply-To: <20120416081532.GA3238@opensource.wolfsonmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Grant Likely <grant@secretlab.ca>, Linus Walleij <linus.walleij@stericsson.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux@openrisc.net, "linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>, sparclinux@vger.kernel.org, Chris Zankel <chris@zankel.net>

On Mon, Apr 16, 2012 at 10:15 AM, Mark Brown
<broonie@opensource.wolfsonmicro.com> wrote:
> On Mon, Apr 16, 2012 at 09:21:58AM +0200, Linus Walleij wrote:
>
>> This looks good but I think we need to page the alpha, ia64, m68k, micro=
blaze,
>> openrisc etc subarch maintainers on this patch so they have their say.
>
> That's why I CCed linux-arch, to get all the architecture maintainers
> included. =A0vger would get upset if I CCed everyone individually.

Oh I missed it. I looped in a few maintainers and arch lists anyway.
Acked-by: Linus Walleij <linus.walleij@linaro.org>

Thanks!
Linus Walleij
