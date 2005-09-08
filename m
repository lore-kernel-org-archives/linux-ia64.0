From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 08 Sep 2005 04:48:49 +0000
Subject: Re: [PATCH 2.6.13 1/3] Minor cleanups - remove unnecessary function
Message-Id: <431FC2B1.80203@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <431E74CE.2090305@jp.fujitsu.com>
In-Reply-To: <431E74CE.2090305@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:
> On Wed, Sep 07, 2005 at 02:04:14PM +0900, Kenji Kaneshige wrote:
> 
>>The function prototype for handl_IRQ_event() in include/asm-ia64/irq.h
>>is no longer needed. This patch removes it.
> 
> 
> Seems to me it can go away from every other architecture that's using
> GENERIC_HARDIRQS (ie frv i386 ia64 m32r mips parisc ppc ppc64 sh sh64
> um x86_64 xtensa).  Mind doing that for everyone?

Sure.
I'll to try to make other patches for these architectures.

Thanks,
Kenji Kaneshige
