From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 Aug 2000 01:29:07 +0000
Subject: Re: [Linux-ia64] Re: IA-64 XFree86 (was: XFree 4.0.1 module loading)
Message-Id: <marc-linux-ia64-105590678205370@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205362@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 21 Aug 2000 12:34:11 -0700 (PDT), Mark Vojkovich <mvojkovich@valinux.com> said:

  Mark> 1) Firmware issues that prevent the X-server from working
  Mark> reliably with SMP (even lspci locks up in the SAL code).

As Bill already pointed out, we have seen any problems since we fixed
/proc/bus/pci/devices not to overwrite kernel memory.  We have a
dual-CPU BigSur here which runs X fine and lspci doesn't crash the
machine.  The quick and dirty hack is to use 16KB page size.

  Mark> 2) No mechanism for the X-server to write combine memory and
  Mark> no discussions on adding this to Linux as far as I can tell.
  Mark> There needs to be a new flag to open() or mmap().  There
  Mark> aren't any MTRRs.

I submitted a patch for the tdfx DRM module to map non-AGP stuff as
write-combined (actually, I'm not 100% sure this is the right thing to
do here; a DRM expert may want to double check this; it does seem to
work fine on my machine).  See the latest Linux kernel patch.

Linus already agreed that it would be OK to add additional mmap()
flags to indicate the memory attribute (normal vs. write-combine
vs. uncached).  Walt says a patch to do this was developed as part of
the XFree86 4.0 work at VA and promised to send me a patch.  I don't
think I have received such a patch, but I'd be happy to merge it
in. ;-)

  Mark> 3) The bios not assigning interrupts to cards that need them.
  Mark> My A3 machine will not boot with an NVIDIA card in it for this
  Mark> reason.

Can't help with this.

	--david

