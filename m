From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 19:14:16 +0000
Subject: Re: [PATCH] pcibios_scan_acpi()
Message-Id: <marc-linux-ia64-105639627619580@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105639496518100@msgid-missing>
In-Reply-To: <marc-linux-ia64-105639496518100@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Jun 2003 19:59:01 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> This patch removes an ifdef from the ia64 acpi patch by
  Matthew> defining a new function which takes an acpi_device and a
  Matthew> segment/domain as well as the bus number.

  Matthew> I think pcibios_scan_acpi() is an atrocious name.  Can
  Matthew> someone come up with a better one?

How about acpi_scan_pci_bus_root()?

	--david
