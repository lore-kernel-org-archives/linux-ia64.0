From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Sun, 15 Dec 2013 10:36:57 +0000
Subject: Re: [PATCH 10/10] Kconfig: cleanup SERIO_I8042 dependencies
Message-Id: <20131215103657.GB20197@core.coreip.homeip.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1387040376-26906-1-git-send-email-msalter@redhat.com>
 <1387040376-26906-11-git-send-email-msalter@redhat.com>
 <52ACA43F.2040402@zytor.com>
In-Reply-To: <52ACA43F.2040402@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Sat, Dec 14, 2013 at 10:32:31AM -0800, H. Peter Anvin wrote:
> On 12/14/2013 08:59 AM, Mark Salter wrote:
> > Remove messy dependencies from SERIO_I8042 by having it depend on one
> > Kconfig symbol (ARCH_MIGHT_HAVE_PC_SERIO) and having architectures
> > which need it select ARCH_MIGHT_HAVE_PC_SERIO in arch/*/Kconfig.
> > New architectures are unlikely to need SERIO_I8042, so this avoids
> > having an ever growing list of architectures to exclude.
> > 
> > Signed-off-by: Mark Salter <msalter@redhat.com>
> > CC: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> > CC: Richard Henderson <rth@twiddle.net>
> > CC: linux-alpha@vger.kernel.org
> > CC: Russell King <linux@arm.linux.org.uk>
> > CC: linux-arm-kernel@lists.infradead.org
> > CC: Tony Luck <tony.luck@intel.com>
> > CC: Fenghua Yu <fenghua.yu@intel.com>
> > CC: linux-ia64@vger.kernel.org
> > CC: Ralf Baechle <ralf@linux-mips.org>
> > CC: linux-mips@linux-mips.org
> > CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > CC: Paul Mackerras <paulus@samba.org>
> > CC: linuxppc-dev@lists.ozlabs.org
> > CC: Paul Mundt <lethal@linux-sh.org>
> > CC: linux-sh@vger.kernel.org
> > CC: "David S. Miller" <davem@davemloft.net>
> > CC: sparclinux@vger.kernel.org
> > CC: Guan Xuetao <gxt@mprc.pku.edu.cn>
> > CC: Ingo Molnar <mingo@redhat.com>
> > CC: Thomas Gleixner <tglx@linutronix.de>
> > CC: "H. Peter Anvin" <hpa@zytor.com>
> > CC: x86@kernel.org
> 
> Acked-by: H. Peter Anvin <hpa@linux.intel.com>

How are we going to merge this? In bulk through input tree or peacemeal
through all arches first?

-- 
Dmitry
