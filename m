From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 19 Mar 2007 20:21:59 +0000
Subject: Re: [PATCH] [REVIEW] Fix irqpoll on IA64 (timer interrupt != 0)
Message-Id: <1174335720.13341.588.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070319181336.GC12628@strauss.suse.de>
In-Reply-To: <20070319181336.GC12628@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, Ingo Molnar <mingo@elte.hu>

On Mon, 2007-03-19 at 19:13 +0100, Bernhard Walle wrote:
> That requires changes in Linux-generic files. The default of timer_irq is 0, so
> the patch doesn't break i386/x86_64. However, other platforms also may also
> have a timer interrupt non-equal to zero, so they can also use the new
> set_timer_interrupt() function.
> 
> The patch is against 2.6.21-rc4. Please give me your input how to improve
> the way it's done if you don't like the way I did the change. irqpoll is
> required to work with kdump in some situations and that's why I discovered
> that kdump doesn't work on that platform (HP rx2660).
> 
> 
> Signed-off-by: Bernhard Walle <bwalle@suse.de>

Acked-by: Thomas Gleixner <tglx@linutronix.de>



