From: Pavel Machek <pavel@suse.cz>
Date: Fri, 04 Mar 2005 22:57:10 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <20050304225710.GB2647@elf.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org> <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk> <200503010910.29460.jbarnes@engr.sgi.com> <20050304135429.GC3485@openzaurus.ucw.cz> <1109975846.5680.305.camel@gaston>
In-Reply-To: <1109975846.5680.305.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, linux-pci@atrey.karlin.mff.cuni.cz, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, "Luck, Tony" <tony.luck@intel.com>

Hi!

> > Hmm, before we go async way (nasty locking, no?) could driver simply
> > ask "did something bad happen while I was sleeping?" at begining of each
> > function?
> > 
> > For DMA problems, driver probably has its own, timer-based,
> > "something is wrong" timer, anyway, no?
> 
> No, there is no nasty locking, when the callback happens, pretty much
> all IOs have stopped anyway due to errors, and we aren't on a critical
> code path.

What prevents driver from being run on another CPU, maybe just doing
mdelay() between hardware accesses? 

								Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
