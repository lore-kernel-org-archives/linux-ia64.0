From: Matthew Wilcox <matthew@wil.cx>
Date: Sat, 05 Jul 2008 18:52:53 +0000
Subject: Re: the printk problem
Message-Id: <20080705185253.GQ14894@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no> <alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org> <19f34abd0807051141h4ccfd0ar28660199f2bbf81f@mail.gmail.com>
In-Reply-To: <19f34abd0807051141h4ccfd0ar28660199f2bbf81f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Engelhardt <jengelh@medozas.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org

On Sat, Jul 05, 2008 at 08:41:39PM +0200, Vegard Nossum wrote:
> Single letters are bad because it hurts readability and limits the
> usefulness of the extension.</MHO>

I think you need a little warning noise that goes off in your head that
means "I might be overdesigning this".  Linus' code is elegant and
solves a problem nicely.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
