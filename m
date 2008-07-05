From: Jan Engelhardt <jengelh@medozas.de>
Date: Sat, 05 Jul 2008 14:07:39 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LNX.1.10.0807051606570.28765@fbirervta.pbzchgretzou.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no>  <alpine.LNX.1.10.0807051518500.28765@fbirervta.pbzchgretzou.qr> <19f34abd0807050650y327ca434pfca324fcccc14f06@mail.gmail.com>
In-Reply-To: <19f34abd0807050650y327ca434pfca324fcccc14f06@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org


On Saturday 2008-07-05 15:50, Vegard Nossum wrote:
>
>I think the most elegant solution would be a macro similar to the
>initcall macros, that adds the custom extensions to a table which is
>defined by a special linker section. This allows complete
>decentralization, but I don't think it's possible to do binary search
>on the names anymore.

With an rbtree, you can still do binary search.
