From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 04 Jul 2008 22:58:56 +0000
Subject: Re: the printk problem
Message-Id: <1215212336.8970.6.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	<20080704132716.f1e12554.akpm@linux-foundation.org>
	<20080704204252.GM14894@parisc-linux.org>
In-Reply-To: <20080704204252.GM14894@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, Peter Anvin <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>


> u64 is easy to fix, and I don't know why we haven't.  Just make it
> unsigned long long on all architectures.

Yup. Also, one of the major user of that is to print a struct resource,
which everybody does differently, so we may even look at doing a %pR
that does the nice start..end [attr]..

Ben.


