From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 03 Mar 2004 16:22:27 +0000
Subject: Re: IA64 test report: 2.6.4-rc1 /Lion 2004-3-3: 10/10 pass
Message-Id: <200403030922.27501.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401720DBC@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401720DBC@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wednesday 03 March 2004 4:28 am, Yu, Luming wrote:
> Sorry, correct log

It would be easier to check/comment on these if the logs were
included inline rather than as an attachment.

>  pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for devic=
e 0000:00:1f.1
> ACPI: No IRQ known for interrupt pin A of device 0000:00:1f.1

I thought we had this issue with an SMBus device, but this looks like
the IDE controller.

> acpi_serial_port: zero-length IO port range?

I'm tired of seeing this; I should probably just remove it (or maybe
print it only with "acpi=3Dstrict").

> input: USB HID v1.00 Keyboard [Tangtop Generic KVM104UC] on usb-0000:00:1=
d.1-2.4
> [e00000003ca88440] link (3ca88242) element (3ca8c300)
>  Element !=3D First TD
>   0: [e00000003ca8c1e0] link (3ca8c300) e3 LS Length=3D7 MaxLen=3D7 DT0 E=
ndPt=3D0 Dev=3D5, PID-(SETUP) (buf<a70280)
>   1: [e00000003ca8c300] link (3ca8c360) e3 SPD LS Stalled Babble Length=
=3D2 MaxLen=3D2 DT1 EndPt=3D0 Dev=3D5, PIDi(IN) (buf<a702a0)
>   2: [e00000003ca8c360] link (00000001) e3 LS IOC Active Length=3D0 MaxLe=
n=7Ff DT1 EndPt=3D0 Dev=3D5, PID=E1(OUT) (buf=00000000)
>=20
> drivers/usb/input/hid-core.c: ctrl urb status -75 received

What's up with this?  Something in USB seems unhappy, even though it
seems to work.  David Mosberger has been seeing USB issues as well
(sorry I don't really have any details on that).

