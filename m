From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 05 Jul 2008 18:44:03 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LFD.1.10.0807051142050.2815@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no> <alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org> <alpine.LNX.1.10.0807052039520.28765@fbirervta.pbzchgretzou.qr>
In-Reply-To: <alpine.LNX.1.10.0807052039520.28765@fbirervta.pbzchgretzou.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Vegard Nossum <vegard.nossum@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org



On Sat, 5 Jul 2008, Jan Engelhardt wrote:
> 
> So, and what do you do when you run out of alphanumeric characters?

Did you actually look at my patch?

It's not a single alnum character. It's an arbitrary sequence of alnum 
characters. IOW, my patch allows

	%p6N

or something like that for showing a ipv6 "NIP" format string etc. Or you 
could spell them out even more, although I consider it unlikely that you 
really want to see too many of these, since gcc won't actually be able to 
type-check them (so they will always remain _secondary_ formats).

			Linus
