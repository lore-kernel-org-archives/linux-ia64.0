From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 04 Mar 2005 02:03:29 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <4227C1F1.6040508@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <20050301144211.GI28741@parcelfarce.linux.theplanet.co.uk> <20050301192711.GE1220@austin.ibm.com> <42255971.4070608@jp.fujitsu.com> <20050302192043.GJ1220@austin.ibm.com>
In-Reply-To: <20050302192043.GJ1220@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

Linas Vepstas wrote:
>>If their defaults are no-ops, device
>>maintainers who develops their driver on not-implemented arch should be
>>more careful. 
> 
> Why? People who write device drivers already know if/when they need to
> disable interrupts, and so they already disable if they need it.  

OK, I'll remake them as no-ops.
Nothing will start unless trust in driver folks.

> p.s. I would like to have iochk_read() take struct pci_dev * as an
> argument.  (I could store a pointer to pci_dev in the "cookie" but
> that seems odd).

I'd like to store the pointer and handle all only with the cookie...
Or is it needed to pass different device to iochk_clear() and iochk_read()?


Thanks,
H.Seto

