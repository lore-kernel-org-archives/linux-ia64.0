From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 03 Apr 2003 06:36:47 +0000
Subject: [Linux-ia64] rx2600 console output with management card
Message-Id: <marc-linux-ia64-105590723705386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Does anyone know if there is some trick to getting linux console
output through the management processor on the rx2600?  all the
documentation states that the management card processor output mirrors
the system console when not it it's managment mode -- which it does
until linux starts.

linux console works fine when plugged into the 'normal' serial port
(which is labeled 'console'), but when plugged into the console output
of the management card (via the provided splitter) I see none of
linux's output.  same problem via telnet -- everything stops when efi
stops.

our hp support guy said he thinks hpux uses special /dev entries to
output via the management card, i couldn't verify this.

some extra info :

we boot with console=ttyS0

From the EFI boot maintenance menu I have
* Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100)
* Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100)
* Acpi(HWP0002,700)/Pci(2|0)
selected as output/input/error devices.

from .config
#
# Serial drivers
#
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_ACPI is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_HCDP=y
# CONFIG_SERIAL_8250_EXTENDED is not set

any suggestions appreciated!

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au



