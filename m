From: Bill Nottingham <notting@redhat.com>
Date: Fri, 16 Nov 2001 03:15:06 +0000
Subject: [Linux-ia64] Re: kernel panic on root mount / EFI cant see /boot/efi partition!
Message-Id: <marc-linux-ia64-105590698805524@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jared Egolf (jegolf@yahoo.com) said: 
> Using Redhat 7.2 and in the past 7.1, I cannot configure
> the /boot/efi partition with such a type definition that
> EFI will recognize the file-system and thus use it for
> booting purposes.

Really? It should allow you to set as an EFI system partition,
or any of the various DOS filesystem types, which all work
in testing here.

> Unfortunately, whenever I rebuild a kernel, (currently
> attempting with 2.4.14, but also tried 2.4.10 and have only
> tested on the BigSur), the kernel panics without being
> capable of mounting the root partition.  This occurs even
> with the default configuration of the kernel and I suspect
> the two problems may be linked.

This sounds like you did not make an initrd that contains
the proper SCSI adapter module, or (alternatively) did not
compile it in statically. Alternatively, you may not
have the filesystem type compiled in; did you install
to an ext3 filesystem?

Bill

