From: =?ISO-8859-1?Q?Bj=F6rn?= Torkelsson <torkel@pdc.kth.se>
Date: Thu, 03 Apr 2003 14:35:25 +0000
Subject: Re: [Linux-ia64] rx2600 console output with management card
Message-Id: <marc-linux-ia64-105590723705391@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705386@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705386@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-04-03 at 14:30, Matthew Wilcox wrote:

> There's three methods for finding serial ports that apply to rx2600
> w/ECI card.  First, we parse the HCDP table.  Second, we search the ACPI
> namespace for serial ports.  Third, we walk the PCI busses looking for
> serial ports.
> 
> The two built-in serial ports are in the ACPI namespace, the ECI card
> actually contains a PCI bus where we find the serial ports.  Firmware
> determines which port is listed in the HCDP table according to which
> Console Input & Console Output devices were listed first.  Unfortunately,
> you can't tell which one was selected first, so the safe thing to do is
> make sure only one is listed.

Yup, when only:

Acpi(HWP0002,700)/Pci(1|1)/Uart(9600 N81)/VenMsg(Vt100+)

is listed as output then everything works as it should. Pity I can't
have both the serial port and the on on the ECI card listed :-(

Thanks for your help!

/torkel


