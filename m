From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Mar 2004 20:09:54 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <16463.30226.948230.439549@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Kenji,

Sorry, I lost track of the status of this patch.  Has it been checked
out OK with respect to interrupt probing?

	--david

>>>>> On Mon, 08 Mar 2004 11:49:10 +0900, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> said:

  Kenji> Hi, In ia64 kernel, IOSAPIC's RTEs for PCI interrupts are
  Kenji> unmasked at the boot time before installing device drivers. I
  Kenji> think it is very dangerous.  If some PCI devices without
  Kenji> device driver generate interrupts, interrupts are generated
  Kenji> repeatedly because these interrupt requests are never
  Kenji> cleared. I think RTEs for PCI interrupts should be unmasked
  Kenji> by device driver.
