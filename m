From: Jared Egolf <jegolf@yahoo.com>
Date: Fri, 16 Nov 2001 21:47:43 +0000
Subject: RE: [Linux-ia64] Re: kernel panic on root mount / EFI cant see
Message-Id: <marc-linux-ia64-105590698805532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805524@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805524@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank-you for your reply, it has given me several more
options to think about.  Unfortunately, I misspoke and I've
only been working with Redhat 7.1, and in the past 7.0.  I
got confused with some of our 32-bit machines where we have
moved to 7.2.  I checked anyway and it wasn't an issue with
ext3 being setup.

As you mentioned below, I'm highly suspicious of the
Microsoft tools getting first crack at the machine.  Did
you have to resort to anything special to remove trace of
them from either the harddrive or the EFI bios setup?  We
are hoping that we won't have to flash the bios to remove
settings, but if it comes to that...

Thank-you for your help,
Jared Egolf

From: "Cook, Steven C" <steven.c.cook@intel.com>
To: 
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] Re: kernel panic on root mount /
EFI cant see /boot/efi partition!
Date: Fri, 16 Nov 2001 08:57:31 -0800

> From: Bill Nottingham [mailto:notting@redhat.com]
> Sent: Thursday, November 15, 2001 19:15
> 
> Jared Egolf (jegolf@yahoo.com) said: 
> > Using Redhat 7.2 and in the past 7.1, I cannot
configure
> > the /boot/efi partition with such a type definition
that
> > EFI will recognize the file-system and thus use it for
> > booting purposes.
> 
> Really? It should allow you to set as an EFI system
partition,
> or any of the various DOS filesystem types, which all
work
> in testing here.

We're also having no problems with the EFI partition
configured to type 
b
(Win32 VFAT).  We have, however, run into problems using
Microsoft's 
EFI
fdisk & format utilities, so in our lab, only use the Linux
installer
fdisk/disk druid utilities to create the partition.
 
> > Unfortunately, whenever I rebuild a kernel, (currently
> > attempting with 2.4.14, but also tried 2.4.10 and have
only
> > tested on the BigSur), the kernel panics without being
> > capable of mounting the root partition.  This occurs
even
> > with the default configuration of the kernel and I
suspect
> > the two problems may be linked.
> 
> This sounds like you did not make an initrd that contains
> the proper SCSI adapter module, or (alternatively) did
not
> compile it in statically. Alternatively, you may not
> have the filesystem type compiled in; did you install
> to an ext3 filesystem?

This sounds like the problem I had when I first installed
7.2 - every 
kernel
I built panicked, because I hadn't applied the ext3 patches
to the
kernel.org kernel sources.  As soon as I put that support
in (and 
selected
it in my configuration), the kernel panics went away.  Not
sure if this 
is
what is plaguing you, but wanted to share that the symptoms
are similar
(although this only happened to me in 7.2, as 7.1 didn't
have the ext3
support built in.

--steve cook--





__________________________________________________
Do You Yahoo!?
Find the one for you at Yahoo! Personals
http://personals.yahoo.com

