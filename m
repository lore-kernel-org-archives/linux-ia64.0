From: Einar Saltnes <eisa@scali.no>
Date: Fri, 09 Feb 2001 17:28:27 +0000
Subject: [Linux-ia64] Serial console during linux boot
Message-Id: <marc-linux-ia64-105590693005123@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

I'm using the RedHat 7.0 ia64 beta distro (13 Dec 2000) on a couple of
Dual B1-stepping BigSurs. BIOS 84.

I am trying to get the linux boot messages/output over the serial port
as I want to operate it remotely by using a serial console switch +
power switch.

Using getty seems to work OK on different serial port speed settings as
does on common x86 machines.
Directing standard output, standard input and standard error to serial
port in EFIs Boot Option Maintenance Boot Menu with speed 115200, seems
to work OK from power on up to start of linux kernel load. BTW, is it
possible to adjust the serial port speed at this level to e.g. 9600 or
19200?

When ELI starts to load the linux kernel, I am not able to get any
output on the serial console. I have tried with the line

append="console=ttyS0,9600n8"

in the beginning of /boot/efi/eli.cfg. (Console switch port speed also
set to 9600)

In the eli README file is says that append commands are implemented, but
serial is not listed as a valid command.
Is there some way I can direct the linux load-/boot-messages on my
current machines?

Thank you!

Best regards
Einar Saltnes
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

