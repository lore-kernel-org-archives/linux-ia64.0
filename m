From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 07 Sep 2005 15:35:57 +0000
Subject: Re: [PATCH 2.6.13 1/3] Minor cleanups - remove unnecessary function prototype in irq.h
Message-Id: <20050907153557.GA17847@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <431E74CE.2090305@jp.fujitsu.com>
In-Reply-To: <431E74CE.2090305@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 07, 2005 at 02:04:14PM +0900, Kenji Kaneshige wrote:
> The function prototype for handl_IRQ_event() in include/asm-ia64/irq.h
> is no longer needed. This patch removes it.

Seems to me it can go away from every other architecture that's using
GENERIC_HARDIRQS (ie frv i386 ia64 m32r mips parisc ppc ppc64 sh sh64
um x86_64 xtensa).  Mind doing that for everyone?
