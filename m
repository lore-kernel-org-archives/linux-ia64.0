From: "Carron, Thierry" <thierry.carron@hp.com>
Date: Thu, 03 Apr 2003 07:34:26 +0000
Subject: RE: [Linux-ia64] rx2600 console output with management card
Message-Id: <marc-linux-ia64-105590723705388@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705386@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705386@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Ian

We used the following setting :

In order to get the console output to the management board.
->	Boot option maintenance menu=20
->	Select active Console Output Device
-> Select the Console Output Device(s)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(PcAnsi)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100+)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(VtUtf8)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(PcAnsi)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100)
    * Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100+)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(VtUtf8)
      Acpi(HWP0002,700)/Pci(2|0)
-> Save Settings to NVRAM
-> Exit
-> Select active Console Input Device
-> Select the Console Input Device(s)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(PcAnsi)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100+)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(VtUtf8)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(PcAnsi)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100)
    * Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100+)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(VtUtf8)
->  Save Settings to NVRAM
->  Exit
->  Select active Console Standard Error Device
->  Select the Standard Error Device
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(PcAnsi)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100+)
      Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(VtUtf8)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(PcAnsi)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100)
    * Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100+)
      Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(VtUtf8)
      Acpi(HWP0002,700)/Pci(2|0)
    Save Settings to NVRAM
    Exit
->	Cold Reset

-----Message d'origine-----
De : Ian Wienand [mailto:ianw@gelato.unsw.edu.au]
Envoy=E9 : jeudi 3 avril 2003 08:37
=C0 : linux-ia64@linuxia64.org; debian-ia64@lists.debian.org
Objet : [Linux-ia64] rx2600 console output with management card


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

we boot with console=3DttyS0

From the EFI boot maintenance menu I have
* Acpi(PNP0501,0)/Uart(9600 N81)/VenMsg(Vt100)
* Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100)
* Acpi(HWP0002,700)/Pci(2|0)
selected as output/input/error devices.

from .config
#
# Serial drivers
#
CONFIG_SERIAL_8250=3Dy
# CONFIG_SERIAL_8250_ACPI is not set
CONFIG_SERIAL_8250_CONSOLE=3Dy
CONFIG_SERIAL_8250_HCDP=3Dy
# CONFIG_SERIAL_8250_EXTENDED is not set

any suggestions appreciated!

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au



_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

