From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 01 Mar 2005 16:37:24 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <42249A44.4020507@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com>
In-Reply-To: <422428EC.3090905@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linas Vepstas <linas@austin.ibm.com>, "Luck, Tony" <tony.luck@intel.com>

Hidetoshi Seto wrote:
> Hi, long time no see :-)
> 
> Currently, I/O error is not a leading cause of system failure.
> However, since Linux nowadays is making great progress on its
> scalability, and ever larger number of PCI devices are being
> connected to a single high-performance server, the risk of the
> I/O error is increasing day by day.
> 
> For example, PCI parity error is one of the most common errors
> in the hardware world. However, the major cause of parity error
> is not hardware's error but software's - low voltage, humidity,
> natural radiation... etc. Even though, some platforms are nervous
> to parity error enough to shutdown the system immediately on such
> error. So if device drivers can retry its transaction once results
> as an error, we can reduce the risk of I/O errors.
> 
> So I'd like to suggest new interfaces that enable drivers to
> check - detect error and retry their I/O transaction easily.

I have been thinking about PCI system and parity errors, and how to 
handle them.  I do not think this is the correct approach.

A simple retry is... too simple.  If you are having a massive problem on 
your PCI bus, more action should be taken than a retry.

In my opinion each driver needs to be aware of PCI sys/parity errs, and 
handle them.  For network drivers, this is rather simple -- check the 
hardware, then restart the DMA engine.  Possibly turning off 
TSO/checksum to guarantee that bad packets are not accepted.  For SATA 
and SCSI drivers, this is more complex, as one must retry a number of 
queued disk commands, after resetting the hardware.

A new API handles none of this.

	Jeff



