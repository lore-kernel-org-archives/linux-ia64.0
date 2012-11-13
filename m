From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Nov 2012 21:28:11 +0000
Subject: RE: [PATCH 1/1] arch Kconfig: remove references to IRQ_PER_CPU
Message-Id: <3908561D78D1C84285E8C5FCA982C28F19D5F453@ORSMSX108.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1352807948-26920-1-git-send-email-james.hogan@imgtec.com>
In-Reply-To: <1352807948-26920-1-git-send-email-james.hogan@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Hogan <james.hogan@imgtec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "uclinux-dist-devel@blackfin.uclinux.org" <uclinux-dist-devel@blackfin.uclinux.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Mike Frysinger <vapier@gentoo.org>, Richard Kuo <rkuo@codeaurora.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@lin>

> But IRQ_PER_CPU wasn't removed from any of the architecture Kconfig
> files where it was defined or selected. It's completely unused so remove
> the remaining references.

Acked-by: Tony Luck <tony.luck@intel.com>

[Hope someone picks up this whole patch ... otherwise I can take the ia64 hunk]
