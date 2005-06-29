From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Jun 2005 21:29:06 +0000
Subject: RE: problem booting -mm2 kernel on rx2600
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03D0B56F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>What "console=" argument do you normally use?  What is your
>EFI console configuration (particularly ConOut)?

The EFI boot maintenance menu shows this in the "Console Output
Device(s)" menu:

    * Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(PcAnsi)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100+)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(VtUtf8)
    * Acpi(HWP0003,0)/Pci(0|0)

>IIUC, your kernel works fine without Mark's patch, and fails
>with it.  Right?

Yes ... though to expand from my recent discoveries ... until I added
Mark's patch I could boot without a "console=something" option.  Now
it seems to be required.

-Tony
