From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 09 Feb 2001 18:03:29 +0000
Subject: Re: [Linux-ia64] Serial console during linux boot
Message-Id: <marc-linux-ia64-105590693005125@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005123@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005123@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> possible to adjust the serial port speed at this level to e.g. 9600 or
> 19200?
> 
Not sure about that.

> When ELI starts to load the linux kernel, I am not able to get any
> output on the serial console. I have tried with the line
> 
> append="console=ttyS0,9600n8"
> 
> in the beginning of /boot/efi/eli.cfg. (Console switch port speed also
> set to 9600)
> 
> In the eli README file is says that append commands are implemented, but
> serial is not listed as a valid command.

ELI does not work like the PC LILO. The control over ELI displaying
on the serial is done by EFI. So for ELI to handle the serial, this would
mean for it to talk to EFI to switch the console. While possible, this 
feature is clearly not implemented today (at least as far as I know).

Also note that the serial command has NOTHING to do with the console= option
to the kernel. One controls where ELI/LILO would print ITS messages whereas
the latter controls where the kernel console output is directed.

I have the impression you're after the kernel messages.

Have you tried to pass the console="" on the command line of ELI rather than
in the configuration file. If you do so PLEASE KEEP THE double quotes as follows:

	fs0:\> eli vmlinux console="ttyS0,9600n8"

We have seen some strange behavior from the EFI shell with regards to 
parsing the command line.

Alternatively, you may want to try the LILO for IA-64 part of the gnu-efi
package (ftp://ftp.hpl.hp.com/pub/linux-ia64). That is the one I used 
everyday and I know that the redirection of the kernel console works just
fine. This would give you a comparison point to try and narrow down your
problem.

Regards,

-- 
-Stephane

