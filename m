From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 12 Feb 2001 15:45:08 +0000
Subject: Re: [Linux-ia64] Serial console during linux boot
Message-Id: <marc-linux-ia64-105590693005135@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005123@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005123@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
> 
> : eisa@scali9-13:eisa; cat /boot/efi/startup.nsh
> lilo -a -i initrd-2.4.0-0.43smp.img vmlinux-2.4.0-0.43smp root=/dev/sda2
> console=ttyS0,115200n8
> 
You are missing the quotes around the console= command.

> 
> : eisa@scali9-13:eisa; cat /boot/efi/startup.nsh
> lilo -a -i initrd-2.4.0-0.43smp.img vmlinux-2.4.0-0.43smp root=/dev/sda2
> console=tty console=ttyS0,115200n8
> 
You are missing the quotes around the console= command here also.
Here is the valid command:

lilo -a -i initrd-2.4.0-0.43smp.img vmlinux-2.4.0-0.43smp root=/dev/sda2
console=tty0 console="ttyS0,115200n8"

> root=/dev/sda2 console=tty console=ttyS0 115200n8 
> LILO for EFI/IA-64 1.1
> lilo: ignoring trailing 108 characters on command line
> kernel     is  'vmlinux-2.4.0-0.43smp'
> arguments  are 'root=/dev/sda2 console=tty console=ttyS0 115200n8'
                                                     ^^^^^^^^^^^^^^
You see here that without quotes, the comma is dropped and the kernel simply
ignores the option. That's why you don't see anything.

> 
> I use the "out of box" RedHat 7.0 smp kernel from the Dec 13 2000 beta
> distro.
> 
> I have tried to grep for the "_PRT is missing package" but it didn't
Because this is a composite message coming from the ACPI code.

Hope this fixes it this time !

-- 
-Stephane

