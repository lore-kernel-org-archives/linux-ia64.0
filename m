From: Linus Torvalds <torvalds@osdl.org>
Date: Fri, 06 Oct 2006 18:09:51 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.64.0610061109100.3952@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Fri, 6 Oct 2006, Luck, Tony wrote:

> please pull from:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

Pulled.

> I think we also need to have a
> 
> 	EXPORT_PER_CPU_SYMBOL_GPL(__irq_regs);
> 
> in libs/irq_regs.c.  I'm seeing errors like:

Yes. This should already be fixed in my current tree.

		Linus
