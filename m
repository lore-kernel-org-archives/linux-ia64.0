From: Linas Vepstas <linas@austin.ibm.com>
Date: Fri, 04 Mar 2005 16:46:25 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <20050304164625.GU1220@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <20050301144211.GI28741@parcelfarce.linux.theplanet.co.uk> <20050301192711.GE1220@austin.ibm.com> <42255971.4070608@jp.fujitsu.com> <20050302192043.GJ1220@austin.ibm.com> <4227C1F1.6040508@jp.fujitsu.com>
In-Reply-To: <4227C1F1.6040508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

On Fri, Mar 04, 2005 at 11:03:29AM +0900, Hidetoshi Seto was heard to remark:
> >p.s. I would like to have iochk_read() take struct pci_dev * as an
> >argument.  (I could store a pointer to pci_dev in the "cookie" but
> >that seems odd).
> 
> I'd like to store the pointer and handle all only with the cookie...

OK then.

> Or is it needed to pass different device to iochk_clear() and iochk_read()?

No.

--linas
