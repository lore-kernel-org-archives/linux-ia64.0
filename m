From: Christoph Hellwig <hch@lst.de>
Date: Sat, 21 Jul 2007 16:53:26 +0000
Subject: Re: revising [patch] add arch_ptrace_stop() hook and use it on ia64
Message-Id: <20070721165326.GA4150@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070720191246.GA19523@lst.de>
In-Reply-To: <20070720191246.GA19523@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 20, 2007 at 02:43:28PM -0700, Luck, Tony wrote:
> > Is anyone ia64-savy interested in revising the patch posted by David in
> > http://marc.info/?l=linux-kernel&m1575781225495&w=2 ?
> >
> > This would allow for converting ia64 to the generic ptrace code,
> > something I would love to see.
> 
> Aren't we heading towards "utrace" as a ptrace replacement?

I don't think so.  Getting in a monolitic patch that redoes all the
debugging is quite impossible, nevermind the problems with all the
overengineering and locking in there.  Instead Alexey is looking into
redoing the important bits from ptrace in small steps and I'm trying
to help him a little with that.  Having everyone use the generic
sys_ptrace would be a very useful step in that direction.
