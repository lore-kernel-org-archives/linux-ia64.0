From: Andi Kleen <ak@muc.de>
Date: Tue, 22 Feb 2005 12:08:41 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <m1wtt0lrue.fsf@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<20050222020309.4289504c.akpm@osdl.org>
In-Reply-To: <20050222020309.4289504c.akpm@osdl.org> (Andrew Morton's
 message of "Tue, 22 Feb 2005 02:03:09 -0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton <akpm@osdl.org> writes:
>
> Is it possible to avoid consuming a page flag?
>
> If this is an ia64-only (or 64-bit-only) thing I guess we could use bit 32.

It's not. i386 essentially has the same problem. Other architectures
likely too. We definitely need a generic solution, especially when
we're going to support PAT on i386/x86-64 better (which I hope will
happen soon)

-Andi
