From: Bernhard Walle <bwalle@suse.de>
Date: Mon, 23 Jul 2007 13:14:02 +0000
Subject: Re: revising [patch] add arch_ptrace_stop() hook and use it on ia64
Message-Id: <20070723131402.GA26416@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070720191246.GA19523@lst.de>
In-Reply-To: <20070720191246.GA19523@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Christoph Hellwig <hch@lst.de> [2007-07-20 21:12]:
> Is anyone ia64-savy interested in revising the patch posted by David in
> http://marc.info/?l=linux-kernel&m1575781225495&w=2 ?
> 
> This would allow for converting ia64 to the generic ptrace code,
> something I would love to see.

Looking into the archive, there were some concerns about SIGKILL
handling. See http://marc.info/?l=linux-ia64&m1577337511750&w=2.

Roland, did you look into that issue?


Thanks,
   Bernhard
