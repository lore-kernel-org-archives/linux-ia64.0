From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 02 Aug 2002 21:47:06 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905895@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 2 Aug 2002 15:44:26 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> iosapic_init_pci_irq() is the only thing in iosapic.c that
  Bjorn> uses ACPI directly.

This routine will change a lot if we switch over to using the
corresponding ACPI code.  I'll see if I can prototype this in 2.5
today.

	--david

