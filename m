From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 28 Mar 2001 17:12:05 +0000
Subject: Re: [Linux-ia64] Deterimining EFI device number within Linux?
Message-Id: <marc-linux-ia64-105590693005363@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005359@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005359@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 Mar 2001 17:18:50 -0600, Matt_Domsch@Dell.com said:

  Matt> Does anyone know how to determine the EFI Device Number (such
  Matt> as 0x80) for a disk known as /dev/sda, under Linux (ideally
  Matt> from user-space, but I'd take a kernel-space trick too)?
  Matt> There's an equivalent problem in IA-32 which has no known
  Matt> solution.  I'm hoping there is for EFI<->Linux.

I imagine you'd have to determine the hardware path to do so.  I'm not
sure of the format used by EFI (I think it follows some standard, but
I'm not familiar with the details), but I'd expect that you'd need to
know the SCSI id, PCI bus, slot & function number of the controller,
the sequence of PCI bridges from the CPU to the device, etc.  Linux
has all this information in one place or another (ioctl(), /proc/pci,
etc.), but it probably won't be pretty.

	--david

