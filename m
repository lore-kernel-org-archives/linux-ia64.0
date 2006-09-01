From: John Keller <jpk@sgi.com>
Date: Fri, 01 Sep 2006 16:01:20 +0000
Subject: [PATCH 0/3] - Altix: Add initial ACPI IO support
Message-Id: <20060901160120.30625.14877.92881@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, ayoung@sgi.com, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>, pcihpd-discuss@lists.sourceforge.net

Patch set to add initial ACPI IO support to Altix.

1/3 acpi-base-support.patch
      When booting with an ACPI capable PROM, the
      DSDT will now define the system nodes and root
      PCI busses. An Altix specific ACPI driver will be
      registered for the node devices, while the
      standard acpi_pci_root_driver can now scan
      the PCI busses, eliminating the need for the current
      fixup code to manually initiate the scan. Multiple SAL
      calls are no longer needed, as platform specific info
      is now passed via the ACPI vendor resource descriptor
      (though all the old fixup code still remains due
      to backward compatability requirements).

      A new platform vector for bus_fixup is created.
      The size of io_space[] is increased to support large
      IO configurations.

2/3 acpi-hotplug.patch
      Make necessary changes to hotplug code now that
      bus fixup is done via platform vector.

3/3 acpi-rom-shadow.patch
      Provide support for PROM shadowing of a ROM image.
