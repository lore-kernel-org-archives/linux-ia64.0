From: "Cook, Steven C" <steven.c.cook@intel.com>
Date: Fri, 16 Nov 2001 16:57:31 +0000
Subject: RE: [Linux-ia64] Re: kernel panic on root mount / EFI cant see /b
Message-Id: <marc-linux-ia64-105590698805529@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805524@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805524@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: Bill Nottingham [mailto:notting@redhat.com]
> Sent: Thursday, November 15, 2001 19:15
> 
> Jared Egolf (jegolf@yahoo.com) said: 
> > Using Redhat 7.2 and in the past 7.1, I cannot configure
> > the /boot/efi partition with such a type definition that
> > EFI will recognize the file-system and thus use it for
> > booting purposes.
> 
> Really? It should allow you to set as an EFI system partition,
> or any of the various DOS filesystem types, which all work
> in testing here.

We're also having no problems with the EFI partition configured to type b
(Win32 VFAT).  We have, however, run into problems using Microsoft's EFI
fdisk & format utilities, so in our lab, only use the Linux installer
fdisk/disk druid utilities to create the partition.
 
> > Unfortunately, whenever I rebuild a kernel, (currently
> > attempting with 2.4.14, but also tried 2.4.10 and have only
> > tested on the BigSur), the kernel panics without being
> > capable of mounting the root partition.  This occurs even
> > with the default configuration of the kernel and I suspect
> > the two problems may be linked.
> 
> This sounds like you did not make an initrd that contains
> the proper SCSI adapter module, or (alternatively) did not
> compile it in statically. Alternatively, you may not
> have the filesystem type compiled in; did you install
> to an ext3 filesystem?

This sounds like the problem I had when I first installed 7.2 - every kernel
I built panicked, because I hadn't applied the ext3 patches to the
kernel.org kernel sources.  As soon as I put that support in (and selected
it in my configuration), the kernel panics went away.  Not sure if this is
what is plaguing you, but wanted to share that the symptoms are similar
(although this only happened to me in 7.2, as 7.1 didn't have the ext3
support built in.

--steve cook--

