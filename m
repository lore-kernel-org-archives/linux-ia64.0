From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 May 2004 17:43:23 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16535.54843.857029.472041@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 May 2004 09:54:09 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> Background: in an effort to allow option ROM emulation on
  Jesse> ia64 (via the X int10+x86 emulator), I've had to look at
  Jesse> doing I/O error recovery since many option ROMs expect to do
  Jesse> legacy I/O port reads and writes to ports that may or may not
  Jesse> respond (one particular ROM that I've looked at continuously
  Jesse> polls a register in legacy I/O space until it returns a
  Jesse> value).  On sn2, when a device doesn't respond to an I/O
  Jesse> (legacy space or otherwise), a PCI master abort is generated,
  Jesse> which generally causes an MCA.

  Jesse> Recovering from such an event requires reprogramming chipset
  Jesse> and bridge registers (some to just clear error state and
  Jesse> others to re-arm error detection) and as such is very
  Jesse> platform specific.  Another issue is that the MCA event may
  Jesse> arrive after the processor has switched to a task completely
  Jesse> unrelated to the I/O.  The approach I've taken thus far is to
  Jesse> register the I/O address range that a process mmaps in
  Jesse> /proc/bus/pci (in pci_mmap_page_range), along with its
  Jesse> associated PID.  When an MCA occurs, an I/O error recovery
  Jesse> routine checks the target identifier value against the linked
  Jesse> list of I/O ranges and recovers appropriately (the PID is
  Jesse> there so that we can send a SIGBUS or somesuch in the
  Jesse> future).  This allows us to avoid calling PAL_MC_DRAIN on
  Jesse> every interrupt to try and flush out errors (which I'm
  Jesse> guessing would be very expensive), but may have other
  Jesse> problems.

  Jesse> Ultimately, this involves adding a machine vector for I/O
  Jesse> error recovery and a linked list of I/O regions and their
  Jesse> PIDs.  The I/O error handler could optionally be extended to
  Jesse> look for any PCI resource range and call a per-device error
  Jesse> handling callback or shutdown routine.

  Jesse> Thoughts?  Does this approach sound reasonable?

Eh, I/O space is required to soft-fail, isn't it?

Why can't you hide this in the platform-specific inX/outX routines?  I
suppose it would be very slow to drain MCAs after every inX/outX, but
you'd have to do the slow part only once, until you know whether or
not the given I/O address is safe.

	--david
