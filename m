From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Mon, 14 Apr 2003 12:55:19 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.67)
Message-Id: <marc-linux-ia64-105590723705490@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Added Cc: to Greg KH and acpi-devel list]

From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: [Linux-ia64] kernel update (relative to v2.5.67)
Date: Fri, 11 Apr 2003 21:28:29 -0700
Message-ID: <200304120428.h3C4STTw004554@napali.hpl.hp.com>

> This kernel was tested on various zx1-based machines and the HP Ski
> simulator.  I also tried it on a Big Sur, but it failed with ACPI
> errors (attached below).  Perhaps someone who actually understands
> ACPI could look into this?  It's also possible that the firmware on my
> Big Sur is too old.  So before digging into this too deep, you may
> want to make sure you have the latest firmware installed.

<snip> 

> ACPI: Subsystem revision 20030328
>     ACPI-0341: *** Error: Handler for [PCI_Config] returned AE_ERROR
>     ACPI-1121: *** Error: Method execution failed [\_SB_.CBN_._BBN] (Node e000000005340900), AE_ERROR
>     ACPI-0098: *** Error: Method execution failed [\_SB_.CBN_._BBN] (Node e000000005340900), AE_ERROR
> kernel unaligned access to 0x000000000000059d, ip=0xe0000000048a9821
>     ACPI-0341: *** Error: Handler for [PCI_Config] returned AE_ERROR
>     ACPI-1121: *** Error: Method execution failed [\PLAT] (Node e00000003f22f840), AE_AML_NO_RETURN_VALUE
>     ACPI-1121: *** Error: Method execution failed [\_SB_.PCI2._STA] (Node e000000005347e00), AE_AML_NO_RETURN_VALUE

It seems that newly integrated PCI segment support is incomplete.

In acpi/osl.c, it does PCI configuration space access like:

  struct pci_bus bus;
  ..
  bus.number = __bus_number_to_access__;
  pci_root_ops->write(&bus, ...);

But the ia64 dependent pci_root_ops uses &bus->sysdata to know
which PCI segment to access:(

I also noticed that in acpi/pci_root.c, _SEG is detected but
ignored;)  So segment support is now meanless (though it's easy
to remove these two lines).

	case AE_OK:
		root->id.segment = (u16) value;
		printk("_SEG exists! Unsupported. Abort.\n");	<= !!!!!
		BUG();						<= !!!!!
		break;


To make things worse, ia64 2.5 tree has a dependency loop in
PCI config space initialization.

  1. To access PCI config space, we need in-kernel PCI tree
  2. To construct the PCI tree, we need ACPI namespace to
     detect PCI root bridges
  3. To check whether a PCI root bridge exists, we have to
     execute _STA method
  4. Often _STA method is implemented using PCI config
     space access, so we need to access the config space
  5. To access PCI config space, ...

To resolve this problem,

 a) blindly probe bus 0 - 255, as we did in early days before
    ACPI initialization
 b) resurrect pci_config_read/write functions so that we can access
    pci config space (with segment specified) regardless of in-kernel
    PCI tree
 c) add #ifdef CONFIG_IA64 to acpi/osl.c to make a fake sysdata
    to specify segment
 d) other (any good ideas?)

I think b) is the most straightforward way to solve the situation,
but as it's once removed, it will be hard to persuade everyone;)

And currently segment support is only implemented on ia64
(using bus->sysdata) which seems ad hoc and is not implemented
on i386.  This is also a problem, though it's not so urgent.

Thanks,
---
Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>

