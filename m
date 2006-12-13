From: Horms <horms@verge.net.au>
Date: Wed, 13 Dec 2006 02:58:50 +0000
Subject: Re: [Fastboot] Some PCI devices do not handle kexec reboot nicely
Message-Id: <20061213025848.GH22902@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 11, 2006 at 04:18:12PM -0800, Jay Lan wrote:
> We found in testing that certain PCI devices don't handle the
> kexec'ed kernel reboot gracefully on IA64 Altix. Some GbE card
> would get into a bad state permanently after one reboot, and
> resulted in MCA on the machines when booting kexec'ed kernel
> thereafter. The MCA was a result of a PIO read to the Expansion
> ROM of the card.  We also saw a USB card issuing stale DMA's
> which was queued up prior to the kexec reboot.
> 
> Do you observe similar problems on other platforms? Are the drivers
> supposed to reset the cards when it re-attach to the card on
> the kexec reboot?

I think that the simple answer to that is yes.
However isn't it the case that this simply isn't possible for some
hardware? There was talk of passing a boot parameter to the second
kernel so it knew it was a second kernel and drivers could take
evasive action as needed. I'm not sure what happened to that idea.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

