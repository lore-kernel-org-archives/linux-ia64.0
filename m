From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 16:54:09 +0000
Subject: [RFC] I/O MCA recovery
Message-Id: <200405040954.09524.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Background: in an effort to allow option ROM emulation on ia64 (via the X 
int10+x86 emulator), I've had to look at doing I/O error recovery since many 
option ROMs expect to do legacy I/O port reads and writes to ports that may 
or may not respond (one particular ROM that I've looked at continuously polls 
a register in legacy I/O space until it returns a value).  On sn2, when a 
device doesn't respond to an I/O (legacy space or otherwise), a PCI master 
abort is generated, which generally causes an MCA.

Recovering from such an event requires reprogramming chipset and bridge 
registers (some to just clear error state and others to re-arm error 
detection) and as such is very platform specific.  Another issue is that the 
MCA event may arrive after the processor has switched to a task completely 
unrelated to the I/O.  The approach I've taken thus far is to register the 
I/O address range that a process mmaps in /proc/bus/pci (in 
pci_mmap_page_range), along with its associated PID.  When an MCA occurs, an 
I/O error recovery routine checks the target identifier value against the 
linked list of I/O ranges and recovers appropriately (the PID is there so 
that we can send a SIGBUS or somesuch in the future).  This allows us to 
avoid calling PAL_MC_DRAIN on every interrupt to try and flush out errors 
(which I'm guessing would be very expensive), but may have other problems.

Ultimately, this involves adding a machine vector for I/O error recovery and a 
linked list of I/O regions and their PIDs.  The I/O error handler could 
optionally be extended to look for any PCI resource range and call a 
per-device error handling callback or shutdown routine.

Thoughts?  Does this approach sound reasonable?

Thanks,
Jesse
