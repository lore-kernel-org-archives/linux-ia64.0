From: Einar Saltnes <eisa@scali.no>
Date: Mon, 12 Feb 2001 15:01:55 +0000
Subject: Re: [Linux-ia64] Serial console during linux boot
Message-Id: <marc-linux-ia64-105590693005133@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005123@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005123@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi again,

Stephane Eranian wrote:
> 
> Also note that the serial command has NOTHING to do with the console= option
> to the kernel. One controls where ELI/LILO would print ITS messages whereas
> the latter controls where the kernel console output is directed.
> 
> I have the impression you're after the kernel messages.
> 
Yes, I guess that is the correct terms of it.

> Alternatively, you may want to try the LILO for IA-64 part of the gnu-efi
> package (ftp://ftp.hpl.hp.com/pub/linux-ia64). That is the one I used
> everyday and I know that the redirection of the kernel console works just
> fine. This would give you a comparison point to try and narrow down your
> problem.
> 

I switched to lilo as you suggested. I also switched to 115200 baud all
the way on the serial port (activated std output and std input on the
serial port from the Boot Option Maintenance Menu and getty in the
/etc/inittab file).
I wasn't aware that the kernel supported Higher baud rates than 9600 or
19200.

However, I still have problems with the kernel messages on the serial
console during linux start up.

Here is how my startup.nsh file look:

: eisa@scali9-13:eisa; cat /boot/efi/startup.nsh
lilo -a -i initrd-2.4.0-0.43smp.img vmlinux-2.4.0-0.43smp root=/dev/sda2
console=ttyS0,115200n8

This would give no kernel messages on the serial console and it would
not give kernel messages on local monitor (tty) either. The last line
printed on the serial console before login prompt was:

_PRT is missing package.

This is similar to the output below.

I also tried with the following startup.nsh file:

: eisa@scali9-13:eisa; cat /boot/efi/startup.nsh
lilo -a -i initrd-2.4.0-0.43smp.img vmlinux-2.4.0-0.43smp root=/dev/sda2
console=tty console=ttyS0,115200n8

This time I got the kernel messages on the local monitor (tty), but
still no messages on the serial console.
Here is the output from the serial console. After this output there will
not be printed any messages before the login prompt appears.

+startup.nsh> lilo -a -i initrd-2.4.0-0.43smp.img vmlinux-2.4.0-0.43smp
root=/dev/sda2 console=tty console=ttyS0 115200n8 
LILO for EFI/IA-64 1.1
lilo: ignoring trailing 108 characters on command line
kernel     is  'vmlinux-2.4.0-0.43smp'
arguments  are 'root=/dev/sda2 console=tty console=ttyS0 115200n8'
Press ENTER to continue or ANY other key to cancel
vmlinux-2.4.0-0.43smp autoboot in   0 seconds
Booting 'vmlinux-2.4.0-0.43smp' with args='root=/dev/sda2 console=tty
console=ttyS0 115200n8'
Press any key to interrupt
Loading kernel Done
Loading initrd Done
Starting kernel at 0xE000000000520000
final arguments  are 'BOOT_IMAGE=vmlinux-2.4.0-0.43smp root=/dev/sda2
console=tty console=ttyS0 115200n8'
acpi_get_vectors
origin = 000000003F0B0E88
bus = 0
_PRT is missing package


I use the "out of box" RedHat 7.0 smp kernel from the Dec 13 2000 beta
distro.

I have tried to grep for the "_PRT is missing package" but it didn't
help much so far. I will continue to dig into the kernel code.

What am I missing to get this up and running?

BTW, how am I supposed to enter commands in the EFI shell which is
longer than the width of the screen? It doesn't seem to wrap in any way.

Thanks in advance for any help,

Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

