From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Mar 2004 07:22:52 +0000
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <16464.5068.454398.649614@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16463.30226.948230.439549@napali.hpl.hp.com>
	<MDEEKOKJPMPMKGHIFAMAEELHDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAEELHDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: davidm@hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Thu, 11 Mar 2004 09:34:06 +0900, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> said:

  Kenji> Hi, I'm sorry that the report falls behind. I wanted to check
  Kenji> out by using real device driver which uses a probe_irq_on(),
  Kenji> but I don't have appropriate environment now.

  Kenji> Though I didn't check out on a real machine yet, I believe my
  Kenji> patch doesn't have any influence on probe_irq_on() because
  Kenji> current probe_irq_on() calls startup callback to unmask the
  Kenji> RTEs as you said before.

OK, I agree.

Thanks,

	--david
