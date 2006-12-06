From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 06 Dec 2006 06:36:15 +0000
Subject: Re: [PATCH] CPEI gets warning at
Message-Id: <1165386976.3233.428.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4575212A.3020902@jp.fujitsu.com>
	 <20061205221913.1ef416f9.akpm@osdl.org>
In-Reply-To: <20061205221913.1ef416f9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>


> It'd be nice if we could just teach the userspace balancer to not try to
> move perpcu IRQs?
> 
> otoh, the patch is super-cheap.   Arjan?

I can fix irqbalance no problem, however I like the kernel approach as
well, since it's not just irqbalance that moves irqs, sysadmins tend to
do it as well....  so how about both?

One thing we probably should do, and that would help irqbalance
immensely, is to export a bitmask for which cpus an interrupt CAN go to,
next to where the current binding interface is. I'll check into that

Hidetoshi: would it be possible to send me a /proc/interrupts file of
that machine?


-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

