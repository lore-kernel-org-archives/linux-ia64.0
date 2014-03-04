From: David Miller <davem@davemloft.net>
Date: Tue, 04 Mar 2014 21:47:59 +0000
Subject: Re: [PATCH 1/2] sched: Remove unused mc_capable() and smt_capable()
Message-Id: <20140304.164759.2230363367739786819.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140304210621.16893.8772.stgit@bhelgaas-glaptop.roam.corp.google.com>
	<20140304210737.16893.54289.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140304210737.16893.54289.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bhelgaas@google.com
Cc: peterz@infradead.org, mingo@redhat.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 04 Mar 2014 14:07:37 -0700

> Remove mc_capable() and smt_capable().  Neither is used.
> 
> Both were added by 5c45bf279d37 ("sched: mc/smt power savings sched
> policy").  Uses of both were removed by 8e7fbcbc22c1 ("sched: Remove stale
> power aware scheduling remnants and dysfunctional knobs").
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Acked-by: David S. Miller <davem@davemloft.net>
