From: David Miller <davem@davemloft.net>
Date: Tue, 04 Mar 2014 21:48:06 +0000
Subject: Re: [PATCH 2/2] sparc64: Remove unused sparc64_multi_core
Message-Id: <20140304.164806.1723542180554308406.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140304210621.16893.8772.stgit@bhelgaas-glaptop.roam.corp.google.com>
	<20140304210744.16893.75929.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140304210744.16893.75929.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bhelgaas@google.com
Cc: peterz@infradead.org, mingo@redhat.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 04 Mar 2014 14:07:44 -0700

> Remove sparc64_multi_core because it's not used any more.
> 
> It was added by a2f9f6bbb30e ("Fix {mc,smt}_capable()"), and the last uses
> were removed by e637d96bf462 ("sched: Remove unused mc_capable() and
> smt_capable()").
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Acked-by: David S. Miller <davem@davemloft.net>
