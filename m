From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Mar 2004 21:37:31 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <16460.59291.774715.188489@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
	<20040308063044.GB25960@cup.hp.com>
In-Reply-To: <20040308063044.GB25960@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Sun, 7 Mar 2004 22:30:44 -0800, Grant Grundler <iod00d@hp.com> said:

  Grant> Hi Kenji, I think this behavior exists to support "legacy"
  Grant> IRQ probing.

I don't think so.  probe_irq_on() calls the "startup" callback which
should do an unmask_irq() for I/O SAPIC.  Can somebody confirm that a
Merced box (without Bjorn's patch) will boot fine with Kenji
Kaneshige's patch applied?

	--david
