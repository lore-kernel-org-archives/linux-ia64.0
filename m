From: Mark Vojkovich <mvojkovich@valinux.com>
Date: Mon, 21 Aug 2000 19:34:11 +0000
Subject: [Linux-ia64] Re: IA-64 XFree86 (was: XFree 4.0.1 module loading)
Message-Id: <marc-linux-ia64-105590678205366@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205362@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 21 Aug 2000, Marc Aurele La France wrote:

> ATI is funding me to go to their labs near Toronto from 2000.09.13 to
> 2000.09.22 and work on IA-64 support.  This despite that they are aware
> Michael Madore has both the ATI and R128 drivers working reasonably well.
> I see this as a measure of how important they feel IA-64 support this.  I
> agree with them.  And so, my goal with this "outing" will be to bring
> XFree86's IA-64 server up to as close to an "out-of-the-box" condition as
> I can, using what we currently provide on IA-32 as a benchmark.
> 
> So that I don't end up duplicating effort and/or working in the dark, I'd
> like us to coordinate our efforts.

   I don't have anything on my worklist for IA-64.  The biggest
problems I have with IA-64 are things that I cannot address. 
Mainly:

1) Firmware issues that prevent the X-server from working reliably
   with SMP (even lspci locks up in the SAL code).

2) No mechanism for the X-server to write combine memory and no
   discussions on adding this to Linux as far as I can tell.
   There needs to be a new flag to open() or mmap().  There
   aren't any MTRRs.

3) The bios not assigning interrupts to cards that need them.
   My A3 machine will not boot with an NVIDIA card in it for
   this reason.

  Other than those, and the fact that we don't have loader
support, the server is pretty much offering what we offer under
IA-32 currently.


					Mark.


