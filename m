From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 12 Apr 2003 04:28:29 +0000
Subject: [Linux-ia64] kernel update (relative to v2.5.67)
Message-Id: <marc-linux-ia64-105590723705486@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At long last, here is an ia64 patch relative to 2.5.67.  As usual, the
ia64 kernel patch is at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.5.67-ia64-030411.diff.gz.

and a detailed changelog is available at
(http://lia64.bkbits.net:8080/to-linus-2.5/).

One of more significant (though small) changes: I replaced the
show_regs() in the MCA INIT platform handler with some code that dumps
the min-state area instead.  The pt_regs structure doesn't contain
terribly interesting data when the INIT handler gets called, and the
backtrace never worked anyhow (because PAL/SAL switch to a different
memory stack before calling the INIT handler).  Also, I added a 5
second delay before the dump starts.  This turns out to be handy when
the console is multiplexed as is the case for zx1-based machines.  On
those, you can generate an INIT event via the base-management
controller's command-line interface.  But to avoid losing output, you
have to switch back in time before the dump starts.  A 5 second delay
achieves that.  If someone has any objections with the delay, let me
know.  I don't think it should be an issue, though, because after the
dump, the machine enters an endless loop anyhow, so what difference
could 5 seconds make?  Having said that, it _would_ be nice if the
INIT handler could be improved to support resuming from INIT events
(when this is possible).  Anyone interested?

This kernel was tested on various zx1-based machines and the HP Ski
simulator.  I also tried it on a Big Sur, but it failed with ACPI
errors (attached below).  Perhaps someone who actually understands
ACPI could look into this?  It's also possible that the firmware on my
Big Sur is too old.  So before digging into this too deep, you may
want to make sure you have the latest firmware installed.

Also, folks with hp zx1-based machines with a remote console management
(ECI) card installed: please make sure you have option
CONFIG_ACPI_8250 turned OFF.  Otherwise, your kernel will get stuck
right after the init process starts running.  Since the 8250_acpi.c
code is only needed for very old zx1-prototypes anyhow, this shouldn't
be any loss.

While it took a while to get this kernel up to speed, it's now working
quite well for me (I'm even running it on my deskside workstation).
Thanks to Alex's sba_iommu, even IDE seems to work nicely again (it
may have been running just fine for some time though, on non-zx1
machines).

So, if you haven't tried 2.5 recently, now might be a good time.

Oh, finally: I hope I didn't miss any patches, but if I did, my
apologies.  Please resend and I'll try to do better next time.

Enjoy,

	--david


ACPI: Subsystem revision 20030328
    ACPI-0341: *** Error: Handler for [PCI_Config] returned AE_ERROR
    ACPI-1121: *** Error: Method execution failed [\_SB_.CBN_._BBN] (Node e000000005340900), AE_ERROR
    ACPI-0098: *** Error: Method execution failed [\_SB_.CBN_._BBN] (Node e000000005340900), AE_ERROR
kernel unaligned access to 0x000000000000059d, ip=0xe0000000048a9821
    ACPI-0341: *** Error: Handler for [PCI_Config] returned AE_ERROR
    ACPI-1121: *** Error: Method execution failed [\PLAT] (Node e00000003f22f840), AE_AML_NO_RETURN_VALUE
    ACPI-1121: *** Error: Method execution failed [\_SB_.PCI2._STA] (Node e000000005347e00), AE_AML_NO_RETURN_VALUE

