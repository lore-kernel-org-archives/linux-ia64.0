From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 04 Mar 2005 02:21:31 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <4227C62B.30504@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <42249A44.4020507@pobox.com> <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org> <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk> <422524B1.10405@jp.fujitsu.com> <20050302174438.GH1220@austin.ibm.com>
In-Reply-To: <20050302174438.GH1220@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

Linas Vepstas wrote:
> Below is some "pseudocode" version (mentally substitute 
> "pci error event" for every occurance of "eeh").  Its got some
> ppc64-specific crud in there that we have to fix to make it 
> truly generic (I just cut and pasted from current code).
> 
> Would a cleaned up version of this code be suitable for a 
> arch-generic pci error recovery framework?  Seto, would 
> this be useful to you?

Yes, it would. I'm looking forward to see your generic one.

Thanks,
H.Seto

