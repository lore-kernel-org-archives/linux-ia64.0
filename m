From: Pavel Machek <pavel@ucw.cz>
Date: Fri, 04 Mar 2005 13:54:29 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <20050304135429.GC3485@openzaurus.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org> <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk> <200503010910.29460.jbarnes@engr.sgi.com>
In-Reply-To: <200503010910.29460.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linas Vepstas <linas@austin.ibm.com>, "Luck, Tony" <tony.luck@intel.com>

Hi!

> > If there's no ->error method, at leat call ->remove so one device only
> > takes itself down.
> >
> > Does this make sense?
> 
> This was my thought too last time we had this discussion.  A completely 
> asynchronous call is probably needed in addition to Hidetoshi's proposed API, 
> since as you point out, the driver may not be running when an error occurs 
> (e.g. in the case of a DMA error or more general bus problem).  The async

Hmm, before we go async way (nasty locking, no?) could driver simply
ask "did something bad happen while I was sleeping?" at begining of each
function?

For DMA problems, driver probably has its own, timer-based,
"something is wrong" timer, anyway, no?
				Pavel

-- 
64 bytes from 195.113.31.123: icmp_seq( ttlQ timeD8769.1 ms         

