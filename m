From: MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com>
Date: Thu, 13 May 2004 09:23:57 +0000
Subject: /proc/ioports regression in 2.6.6 on Tiger4
Message-Id: <20040513.182357.104026513.maeda@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, 

Since 2.6.6, "cat /proc/ioports" loops infinity on Tiger4, because 
there is a loop in ioport_resource tree.

$ cat /proc/ioports 
00000000-00005fff : PCI Bus 0000:00
  00000060-0000006f : i8042
  000001f0-000001f7 : ide0
  000003c0-000003df : vga+
  000003f6-000003f6 : ide0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
          00000500-0000053f : 0000:00:1f.0
	  ... 

$ /sbin/lspci -vs 00:1f.0
00:1f.0 ISA bridge: Intel Corp. 82801DB LPC Interface Controller (rev 02)
        Flags: bus master, medium devsel, latency 0

0000:00:1f.0, which causes the loop, is an Intel LPC interface bridge,
and quirk_ich4_lpc_acpi() has become called for the bridge since 2.6.6.

The reason of the loop is, pci_claim_resource() is issued twice with
the exactly same resource structure, the first one is called by 
quirk_io_region() for quirk_ich4_lpc_acpi() at pci_fixup_device() and
the second one is called by pcibios_fixup_device_resources(), 
and in this condition, insert_resource() sets the resource's child pointer
to itself. Oviously, it causes the loop.

There are a few ways to fix the problem as following, but I'm not sure
which one is the best. 

1) Do not claim the resource in quirk_io_region().
2) Put additional check in pcibios_fixup_device_resources() if the resource
   has already been claimed.
3) Modify insert_resource() not to claim the resource that has already been
   claimed and return with -EBUSY.

Does anybody have comments?

Thanks,
Naoaki Maeda
