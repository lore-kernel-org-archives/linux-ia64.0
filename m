From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sun, 06 Jul 2008 05:17:19 +0000
Subject: Re: the printk problem
Message-Id: <20080705221719.949998e5.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no>
	<alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org>
	<19f34abd0807051141h4ccfd0ar28660199f2bbf81f@mail.gmail.com>
	<20080705185253.GQ14894@parisc-linux.org>
	<84144f020807051702q1fc6275cv358c5e33dc2677fc@mail.gmail.com>
In-Reply-To: <84144f020807051702q1fc6275cv358c5e33dc2677fc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matthew Wilcox <matthew@wil.cx>, Vegard Nossum <vegard.nossum@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Engelhardt <jengelh@medozas.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org

On Sun, 6 Jul 2008 03:02:59 +0300 Pekka Enberg wrote:

> On Sat, Jul 05, 2008 at 08:41:39PM +0200, Vegard Nossum wrote:
> >> Single letters are bad because it hurts readability and limits the
> >> usefulness of the extension.</MHO>
> 
> On Sat, Jul 5, 2008 at 9:52 PM, Matthew Wilcox <matthew@wil.cx> wrote:
> > I think you need a little warning noise that goes off in your head that
> > means "I might be overdesigning this".  Linus' code is elegant and
> > solves a problem nicely.
> 
> Am I the only one who missed Linus' patch? Did it make it to the list?

No, you are not the only one.  It was on linuxppc-dev for some reason.
http://ozlabs.org/pipermail/linuxppc-dev/2008-July/059257.html

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
