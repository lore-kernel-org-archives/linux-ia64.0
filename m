From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 29 Jul 2003 23:06:36 +0000
Subject: Re: [PATCH] improve scalability of 2.4.21 fpassist
Message-Id: <marc-linux-ia64-105952002320917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105726499515305@msgid-missing>
In-Reply-To: <marc-linux-ia64-105726499515305@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 03 July 2003 2:36 pm, John Hawkes wrote:
> This change has already made its way into linux-2.5.72-ia64-031619.diff.
> Here is the diff relative to 2.4.21 + linux-2.4.21-ia64-030702.diff.
> 
> This patch *significantly* improves the scalability of handle_fpu_swa()
> when multiple CPUs are generating concurrent fp-assist traps.
> The original algorithm produces cacheline ping-ponging for the cacheline
> that contains fpu_swa_count.  This new algorithm only dirties
> fpu_sw_count when the printk() is about to occur, rather than on every
> fpassist trap, which throttles the ping-ponging to no more than five per
> second.

I applied this for 2.4.  Thanks!

Bjorn

