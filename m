From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 17 Oct 2000 07:18:26 +0000
Subject: Re: [Linux-ia64] register initialization error on test9 ?
Message-Id: <marc-linux-ia64-105590678205573@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205572@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205572@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Oct 2000 15:13:46 +0900, Hiro Fujita <fujita@kanagawa.hitachi.co.jp> said:

  Hiro> And, this initialization should be done for all application
  Hiro> processors (APs) even if CONFIG_IA64_EARLY_PRINTK is not
  Hiro> defined, because RR[6] is used for translation when printk()
  Hiro> is called by AP.

No, printk normally doesn't write to the console until the memory
subsystem (and PCI) has been initialized, so this code isn't needed
unless EARLY_PRINTK is set.

Aside from that, your patch looks fine.

Thanks,

	--david

