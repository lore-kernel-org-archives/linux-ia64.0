From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 13 Sep 2005 09:34:44 +0000
Subject: Re: 2.6.14-rc1 ia64 rebuilds everything every time
Message-Id: <17190.40244.218855.739759@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <23363.1126593124@kao2.melbourne.sgi.com>
In-Reply-To: <23363.1126593124@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Keith" = Keith Owens <kaos@sgi.com> writes:


Keith> Best solution: remove (and forbid) recursive definitions in
Keith> asm-offset.c.

Unfortunately,I'm not sure that's possible.


Keith> Kludge 2: Build arch/$(ARCH)/kernel/asm-offsets.s as a
Keith> temporary file then check if it has changed or not, only
Keith> updating the real arch/$(ARCH)/kernel/asm-offsets.s if there is
Keith> any change.

This is what used to happen.

Peter C
