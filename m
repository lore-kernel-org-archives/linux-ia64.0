From: Jan Engelhardt <jengelh@medozas.de>
Date: Sat, 05 Jul 2008 11:33:29 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LNX.1.10.0807051332200.28765@fbirervta.pbzchgretzou.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com> <20080704111540.ddffd241.akpm@linux-foundation.org> <alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org> <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
 <20080704132716.f1e12554.akpm@linux-foundation.org> <20080704204252.GM14894@parisc-linux.org> <20080704150100.1f7b8a65.akpm@linux-foundation.org>
In-Reply-To: <20080704150100.1f7b8a65.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org


On Saturday 2008-07-05 00:01, Andrew Morton wrote:
>
>We don't know how much interest there would be in churning NIPQUAD from
>the net guys.  Interestingly, there's also %C (wint_t) which is a
>32-bit quantity.  So we could just go and say "%C prints an ipv4
>address" and be done with it.  But there's no way of doing that for
>ipv6 addresses so things would become asymmetrical there.

	struct in6_addr src;
	printk("Source address: %p{ipv6}\n", &src);

How about %p{feature}?
