From: Gerrit.Huizenga@us.ibm.com
Date: Wed, 09 Aug 2000 10:36:35 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205294@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ditto - I can be logged in remotely all day, no problem.  I can
build things redirecting output to a file, look at that file
periodically during the build without a problem, run top through
an rlogin session, etc. all without a problem.  However, spewing
output from a build seems to pretty reliably cause a lockup or
sometimes a panic/oops.  I'm not set up so that I can catch the
output of an oops (console over serial) so I'll look at it in more
detail next time it happens.

I've also noticed that when the machine "hangs" it isn't really hung
but cc1 is doing a loop of about 10-20 mmap()'s followed by a break();
the panic seems to happen when the machine runs out of swap.

Why it gets into an mmap/break loop is a mystery (to me, at least).

BTW, thanks to all for the comment about -g (I still have a hand-shaped
imprint on my forehead from that one - we had the same problem with our
compilation tools when we first converted to ELF/DWARF; had to write
sysv cprs(1) to be more agressive).  File sizes are more comprehensible.

On a last question, has anyone run a test4 kernel on a 4-proc Lion
(A3 procs, I forget which BIOS/EFI, but fairly recent)?  I keep getting
SCSI timeouts from the qlogics/SCSI driver.  I see a lot of changes
between test1 & test4 in the generic SCSI code, a couple of which
might be related (looks like test1 has some improved Inquiry code
that test4 does not have).

The relevent dmesg output is:

	scsi(0): Determining if RISC is loaded...
	scsi(0): Verifying chip...
	scsi(0): Setup chip...
	scsi(0): Configure NVRAM parameters...
	scsi(0): Resetting SCSI BUS (0)
	scsi(0): Resetting SCSI BUS (1)
	scsi0 : QLogic QLA12160 PCI to SCSI Host Adapter: bus 1 device 2 irq 10
	       Firmware version: 10.01.19, Driver version  3.00-Beta
	scsi : 1 host.
	scsi : aborting command due to timeout : pid 0, scsi0, channel 0, id 0, lun 0 Inquiry 00 00 00 ff 00
	scsi(0): ABORT Command=0xe00000007fd06080, handle=0x1
	SCSI host 0 abort (pid 0) timed out - resetting
	SCSI bus is being reset for host 0 channel 0.
	scsi(): Resetting Cmnd=0xe00000007fd06080, Handle=0x1, flags=0x2
	scsi(0:0:0:0): Queueing device reset command.
	SCSI host 0 channel 0 reset (pid 0) timed out - trying harder
	SCSI bus is being reset for host 0 channel 0.
	scsi(): Resetting Cmnd=0xe00000007fd06080, Handle=0x1, flags=0x6
	qla1280(0:0:0:0): Issuing BUS DEVICE RESET.
	scsi(0): Resetting SCSI BUS (0)

I note that the IRQ is 10 on the test4 kernel, my test1 kernel has it as
irq 48, I believe.  Other than that, no apparent differences...

gerrit

> >>>>> "Gerrit" = Gerrit Huizenga <Gerrit.Huizenga@us.ibm.com> writes:
> 
> Gerrit> I noted recently that I couldn't build a kernel on the Lion
> Gerrit> when rlogin'd to the machine, but at the console I seem to
> Gerrit> have no problem.
> 
> Gerrit> Could the problems be a deadlock or other problem in the
> Gerrit> test1/test4 linux tcp code?
> 
> I have actually noticed that my machine seems slightly more stable
> when compiling without spewing the output to a remote window. Ie. if I
> compile XFree in a remote window it is almost certain to lock up, but
> both times I tried running it directing the output from stdout/stderr
> to a local file the build actually completed. This is on a UP A2 Lion
> btw.
> 
> I would actually suspect that eepro100 driver or similar.
> 
> Jes

