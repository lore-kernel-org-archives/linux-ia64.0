From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 24 Aug 2004 08:06:13 +0000
Subject: Re: [RFC&PATCH 1/2] PCI Error Recovery (readX_check)
Message-Id: <412AF6F5.6020806@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <412AD123.8050605@jp.fujitsu.com>
 <Pine.LNX.4.58.0408232231070.17766@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0408232231070.17766@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Linus Torvalds wrote:
> I'd suggest changing the locking a bit.
> 
> Just make "clear_pci_errors()" take a spinlock on the bridge, and 
> "read_pci_errors()" unlock it. We need to make sure that if multiple 
> devices on the same bridge try to be careful, they can do so without 
> seeing each others errors.

... Why spinlock?
Are rwlocks not smart way to decrease the impact on I/O performance?

> I'd also suggest that you make "clear_pci_errors()" return a cookie for 
> read_pci_errors() to use. 

What I can only imagine is... passing somthing like a identifier of
looking bridge to driver as cookie, functionally, it's sounds good.
... Are there any other useful usages of the cookie?

> Also, I assume that the thing would support (and please make the
> documentation clear on it) multiple IO operations between a
> "clear_pci_errors()" and it's ending "read_pci_errors()" pair.

Sure.
So taking a spinlock between this pair clearly means long time locking on
I/O, this will block all other I/O under same bridge, I think this isn't
good situation.  Still do we take a spinlock?


Thanks,
H.Seto
