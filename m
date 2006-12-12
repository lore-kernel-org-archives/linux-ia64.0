From: Jay Lan <jlan@sgi.com>
Date: Tue, 12 Dec 2006 00:18:12 +0000
Subject: Some PCI devices do not handle kexec reboot nicely
Message-Id: <457DF544.1000009@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We found in testing that certain PCI devices don't handle the
kexec'ed kernel reboot gracefully on IA64 Altix. Some GbE card
would get into a bad state permanently after one reboot, and
resulted in MCA on the machines when booting kexec'ed kernel
thereafter. The MCA was a result of a PIO read to the Expansion
ROM of the card.  We also saw a USB card issuing stale DMA's
which was queued up prior to the kexec reboot.

Do you observe similar problems on other platforms? Are the drivers
supposed to reset the cards when it re-attach to the card on
the kexec reboot?

Thanks,
 - jay

