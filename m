From: "David S. Miller" <davem@davemloft.net>
Date: Sat, 19 Mar 2005 04:05:55 +0000
Subject: Re: [patch] arch hook for notifying changes in PTE protections bits
Message-Id: <20050318200555.2d1980f6.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318162943.A3157@unix-os.sc.intel.com>
In-Reply-To: <20050318162943.A3157@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davidm@hpl.hp.com


This is way overkill I think.

Take a look at set_pte_at().  You get the "mm", the
virtual address, the pte pointer, and the new pte value.

What else could you possibly need to track stuff like this
and react appropriately? :-)

It is even an argument for batched TLB processing on ia64.
It simplifies a lot of cache flushing issues and you can
control the flushing on a per-translation basis however
you like.
