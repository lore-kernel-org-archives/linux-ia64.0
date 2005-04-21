From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 21 Apr 2005 13:39:26 +0000
Subject: [RFC/PATCH 0/3] ACPI based I/O APIC hot-plug
Message-Id: <4267AD0E.3080006@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Len Brown <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Greg KH <greg@kroah.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net

Hi,

Here is a set of patches to support ACPI based I/O APIC hotplug. This
code consists of the following three patches.

    - Add the new interfaces for I/O APIC hot-add/hot-remove. The
      implementation of these interfaces depends on each architecture.

    - IA64 implementation of above-mentioned interfeces for I/O APIC
      hot-add/hot-remove.

    - Add I/O APIC hot-add support to ACPIPHP dirver. PCI root bridge
      hot-add will be fully functional with this patch. This will be
      also needed to support hot-add of p2p bridge hierarchy that
      contains I/O APICs. This code supports only hot-add for now.

These patches support I/O APIC hot-plug on ia64 only for now. These
are against 2.6.12-rc2-mm3.

Thanks,
Kenji Kaneshige
