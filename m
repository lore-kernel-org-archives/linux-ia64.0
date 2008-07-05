From: Jan Engelhardt <jengelh@medozas.de>
Date: Sat, 05 Jul 2008 18:40:07 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LNX.1.10.0807052039520.28765@fbirervta.pbzchgretzou.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no> <alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vegard Nossum <vegard.nossum@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org


On Saturday 2008-07-05 19:56, Linus Torvalds wrote:
>> >
>> > How about %p{feature}?
>
>No.
>
>I _expressly_ chose '%p[alphanumeric]*' because it's basically 
>totally insane to have that in a *real* printk() string: the end result 
>would be totally unreadable.

So, and what do you do when you run out of alphanumeric characters?
