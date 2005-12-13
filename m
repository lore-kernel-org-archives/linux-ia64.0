From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Tue, 13 Dec 2005 18:59:00 +0000
Subject: Re: [2.6 patch] don't allow users to set CONFIG_BROKEN=y
Message-Id: <9a8748490512131059m54cc56faueaab6ddf0f18520e@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051211185212.GQ23349@stusta.de>
	 <20051211192109.GA22537@flint.arm.linux.org.uk>
	 <20051211193118.GR23349@stusta.de>
	 <20051211194437.GB22537@flint.arm.linux.org.uk>
	 <20051213001028.GS23349@stusta.de> <439ECDCC.80707@hogyros.de>
	 <20051213140001.GG23349@stusta.de>
	 <20051213173112.GA24094@flint.arm.linux.org.uk>
	 <20051213180551.GN23349@stusta.de>
	 <Pine.LNX.4.62.0512131926530.17990@pademelon.sonytel.be>
In-Reply-To: <Pine.LNX.4.62.0512131926530.17990@pademelon.sonytel.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Adrian Bunk <bunk@stusta.de>, Simon Richter <Simon.Richter@hogyros.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org, matthew@wil.cx, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, Paul Mackerras <paulus@samba.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, lethal@linux-sh.org, kkojima@rr.iij4u.or.jp, dwmw2@infradead.org, linux-mtd@lists.infradead.org

On 12/13/05, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Tue, 13 Dec 2005, Adrian Bunk wrote:
> > Do not allow people to create configurations with CONFIG_BROKEN=y.
> >
> > The sole reason for CONFIG_BROKEN=y would be if you are working on
> > fixing a broken driver, but in this case editing the Kconfig file is
> > trivial.
> >
> > Never ever should a user enable CONFIG_BROKEN.
>                       ^^^^
> OK, a user, not an expert. Let's assume users don't enable EXPERIMENTAL.
>
> But I'd like to at least have the possibility to enable broken drivers, even if
> it's just for compile regression tests.
>
I agree, and it's very convenient to be able to enable it in
menuconfig etc. Perhaps CONFIG_BROKEN should just be moved to kernel
hacking instead...?

--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
