From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 28 Jun 2006 16:21:08 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1151511668.15166.34.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
	 <1151483994.3153.5.camel@laptopd505.fenrus.org>
	 <005e01c69ac9$a55e1bf0$6f00a8c0@comcast.net>
In-Reply-To: <005e01c69ac9$a55e1bf0$6f00a8c0@comcast.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Hawkes <hawkes@sgi.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

Ar Mer, 2006-06-28 am 08:43 -0700, ysgrifennodd John Hawkes:
> > #define HZ sysconf(_SC_CLK_TCK)
> 
> That did occur to me.  It obviously does get the correct value.  The downside
> is that one of those crufty apps that thinks it is using "HZ" as a constant
> will instead be invoking a more costly syscall.  Should we care about the
> resulting performance impact?

Given that HZ can be cached by glibc the performance impact is minimal
for most cases. The bigger problem will be code that does things with HZ
that only work on compile time evaluation. At least for those you'll
break at compile time.

Either way its kind of irrelevant, the ABI set HZ. Its done, there are
plenty of ways to change the kernel HZ without confusing userspace.

Alan

