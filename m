From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Thu, 11 Mar 2004 01:34:47 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <20040311.103447.10929472.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16463.30226.948230.439549@napali.hpl.hp.com>
	<MDEEKOKJPMPMKGHIFAMAEELHDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAEELHDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kaneshige.kenji@jp.fujitsu.com
Cc: davidm@hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Date: Thu, 11 Mar 2004 09:34:06 +0900

> Hi,
> 
> I'm sorry that the report falls behind. I wanted to check out by using
> real device driver which uses a probe_irq_on(), but I don't have appropriate
> environment now.
> 
> Though I didn't check out on a real machine yet, I believe my patch doesn't
> have any influence on probe_irq_on() because current probe_irq_on() calls
> startup callback to unmask the RTEs as you said before.

My concern was that if there's a buggy PCI device that raises
interrupts all the time until it's initialized by some device driver,
probe_irq_on() would not work as expected regardless of whether
your patch is applied or not.  I thought masking the interrupt line
doesn't work around this case.

---
Takayoshi Kochi <t-kochi@bq.jp.nec.com>
