From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Jun 2013 21:52:49 +0000
Subject: RE: [PATCH v3 06/27] ia64, irq: Add dummy create_irq_nr()
Message-Id: <3908561D78D1C84285E8C5FCA982C28F2DA79B07@ORSMSX106.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370644273-10495-1-git-send-email-yinghai@kernel.org>
	<1370644273-10495-7-git-send-email-yinghai@kernel.org>
	<20130609152259.GC2245@breakpoint.cc>
 <CAE9FiQWBrUX40Rzn_4hg7whr7B18TLxzBiJPKOZkL+JEk8-Vhw@mail.gmail.com>
In-Reply-To: <CAE9FiQWBrUX40Rzn_4hg7whr7B18TLxzBiJPKOZkL+JEk8-Vhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yinghai Lu <yinghai@kernel.org>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Bjorn Helgaas <bhelgaas@google.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Still need ia64 guys to kill create_irq() in arch/ia64.

Was there already a patch to do that? I'm afraid my eyes tend to glaze over when I
see [part 64/87: ia64 ...] and assume that its general cleanup that will flow through
with all the other parts of the patch series.  Please point me at something that you
want me to apply.

If not - then what is the recommended replacement? There seem to be a half dozen
places in arch/ia64 where create_irq() is called.

-Tony
