From: Arnd Bergmann <arnd@kernel.org>
Date: Thu, 22 Jul 2021 14:01:39 +0000
Subject: Re: [PATCH v3 9/9] asm-generic: reverse GENERIC_{STRNCPY_FROM, STRNLEN}_USER symbols
Message-Id: <CAK8P3a0xZAHknG8_kc62aaKrKdzD-QwQYHT61_wTbFDYADu-zw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210722124814.778059-1-arnd@kernel.org> <20210722124814.778059-10-arnd@kernel.org>
 <29adc1c164805e355b37d1d4668ebda9fb7fa872.camel@sipsolutions.net>
In-Reply-To: <29adc1c164805e355b37d1d4668ebda9fb7fa872.camel@sipsolutions.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Johannes Berg <johannes@sipsolutions.net>
Cc: linux-arch <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Al Viro <viro@zeniv.linux.org.uk>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Brian Cain <bcain@codeaurora.org>, Chris Zankel <chris@zankel.net>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoph Hellwig <hch@lst.de>, Guo Ren <guoren@kernel.org>, Heiko Carstens <hca@linux.ibm.com>, Helge Deller <deller@gmx.de>, Jeff Dike <jdike@addtoit.com>, Linus Walleij <linus.walleij@linaro.org>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek <monstr@monstr.eu>, Richard Weinberger <richard@nod.at>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Vasily Gorbik <gor@linux.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-csky@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, linux-um <linux-um@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>

On Thu, Jul 22, 2021 at 3:57 PM Johannes Berg <johannes@sipsolutions.net> wrote:
>
> >
> > The remaining architectures at the moment are: ia64, mips, parisc,
> > s390, um and xtensa. We should probably convert these as well, but
>
> I'm not sure it makes sense to convert um, the implementation uses
> strncpy(), and that should use the libc implementation, which is tuned
> for the actual hardware that the binary is running on, so performance
> wise that might be better.
>
> OTOH, maybe this is all in the noise given the huge syscall overhead in
> um, so maybe unifying it would make more sense.

Right, makes sense. I suppose if we end up converting mips and s390,
we should just do arch/um and the others as well for consistency, even
if that adds some overhead.

      Arnd
