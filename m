From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 21 Nov 2013 17:39:33 +0000
Subject: Re: [PATCH 24/34] PCI: use weak functions for MSI arch-specific functions
Message-Id: <20131121173933.GT10382@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1384915853-31006-1-git-send-email-r65037@freescale.com>
 <1384915853-31006-24-git-send-email-r65037@freescale.com>
In-Reply-To: <1384915853-31006-24-git-send-email-r65037@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Zhu <r65037@freescale.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Russell King <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Jason Cooper <jason@lakedaemon.net>

On Wed, Nov 20, 2013 at 10:50:43AM +0800, Richard Zhu wrote:

Looking good,

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Nevertheless I'd again like to express that I'm not that fond of of the
increasing number of weak functions in the kernel.  In the old days
things were such that when an a platform didn't provice a platform hook
or enable a default hook function, one would get a build error - an
unmistakable sign to the maintainer that something needs attention.
Weak functions mean default functions may result in subtly incorrect
operation.  Been there, got bitten.

  Ralf
