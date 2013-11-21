From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Thu, 21 Nov 2013 19:08:04 +0000
Subject: Re: [PATCH 24/34] PCI: use weak functions for MSI arch-specific functions
Message-Id: <20131121200804.617d6ae6@skate>
List-Id: <linux-ia64.vger.kernel.org>
References: <1384915853-31006-1-git-send-email-r65037@freescale.com>
        <1384915853-31006-24-git-send-email-r65037@freescale.com>
        <20131121173933.GT10382@linux-mips.org>
In-Reply-To: <20131121173933.GT10382@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Richard Zhu <r65037@freescale.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Russell King <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Jason Cooper <jason@lakedaemon.net>

Dear Ralf Baechle,

On Thu, 21 Nov 2013 18:39:33 +0100, Ralf Baechle wrote:
> On Wed, Nov 20, 2013 at 10:50:43AM +0800, Richard Zhu wrote:
> 
> Looking good,
> 
> Acked-by: Ralf Baechle <ralf@linux-mips.org>

I think this patch was mistakenly sent by Richard Zhu. It is already
part of mainline since 3.12:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/pci/msi.c?idB87d824f265451cd10f6d20266b27a207a6cdd7.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
