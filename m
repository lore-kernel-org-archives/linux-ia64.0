From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 02 Sep 2004 20:38:54 +0000
Subject: Re: HCDP concerns
Message-Id: <200409021438.54810.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4135A3A7.9000706@bull.net>
In-Reply-To: <4135A3A7.9000706@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thursday 02 September 2004 1:09 pm, Xavier Bru wrote:
>  No, I just meant that without CONFIG_EFI_PCDP, we need to fall back
>  to the standart initialization calling setup_serial_legacy().=A0 Without
>  the patch, the test on efi.hcdp returns non zero, and the
>  setup_serial_legacy is not called.

The only benefit of setup_serial_legacy() is that that a serial
console can start working earlier.  If you don't call it, the
serial console will still work after the normal serial driver
initializes.

>  In our case, the EFI has access to 1 serial line, but there are
>  2 serials in the machine, and we used to use the linux console on
>  one or the other serial. Only one line is described in the HCDP
>  (the one of the EFI redirection).

This sounds broken.  If you have an HCDP and you want to use an
early serial console, the HCDP should describe the port you want
to use.

If one of the ports is for use by EFI only, there's no point in
describing that port in the HCDP.

>  I still have some problem of understanding if HCDP should provide
>  information on all potential consoles, or should provide information
>  on the consoles that EFI effectively uses.

>  In the first case, we need still an information on which linux will
>  use (the "console=3D ").

>  In the second case, the "console=3D" could allow using others possible
>  consoles to linux, as linux gave this flexibility before using the
>  HCDP.=A0 But it is maybe sufficient to consider that linux consoles
>  are same as efi consoles.  =20

My goal is certainly to make Linux automatically use the same console
as EFI used.  That is complicated a bit by the fact that EFI can use
multiple devices simultaneously, without any concept of a "primary"
device.  Linux really wants a single device.  (You can use multiple
"console=3D" arguments to get kernel output on several devices, but
eventually init is going to open a single device.)

One of the big problems with the HCDP was that it could describe
several UARTs, but there was no indication of which was the primary.
So Linux only looks at the first entry.  This is one of the things
the PCDP is intended to fix.

Let me restate this to see if I understand what you need:

I think you have ports at 0x3f8 and 0x2f8.  The desired naming
is 0x3f8 =3D ttyS0 and 0x2f8 =3D ttyS1.

With CONFIG_EFI_PCDP=3Dn, you should get the desired naming, and
"console=3DttyS0" or "console=3DttyS1" should both work and go to
the correct ports (but the output won't start until the serial
driver initializes).

With CONFIG_EFI_PCDP=3Dy, the first port in the HCDP becomes ttyS0.
(This is a bug and I'll try to fix it soon.)  "console=3DttyS0"
should work, the output should start early, and it should go to
the first device in the HCDP.  "console=3DttyS1" should also work,
but the output won't start until later, and it should go to the
other port (the one that is NOT described first in the HCDP).

I think what you want is a way to
	(1) get early output, and
	(2) specify the port where the output should go
That's perfectly reasonable, but neither scenario above gives
you that.

Rather than using the hack of assuming ports at 0x3f8 and 0x2f8,
I'd like to use this as an excuse to get the cleaner solution
done.  I'm thinking something like a "console=3Dserial,0x3f8"
argument to specify the device.  Then we don't have to bind a
name to the device, so we get rid of the renaming problem.
And the HCDP/PCDP will become just a default source of the "0x3f8"
information if it's not on the command line.

Would that solve the problem?
