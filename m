From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 08 Jun 2004 15:38:54 +0000
Subject: Re: Who owns those locks ?
Message-Id: <40C5DD8E.8DD37D16@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A1F4BE.4A298352@nospam.org> <200406070906.54132.bjorn.helgaas@hp.com> <40C572C8.20B13640@nospam.org> <200406080905.52673.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Bjorn Helgaas wrote:
>=20
> On Tuesday 08 June 2004 2:03 am, Zoltan Menyhart wrote:
> > - You keep my code, it is correct for a memory size up to 16 Tbytes.
>=20
> Many if not most large machines have sparse address spaces,
> so you may have memory at an address that will cause a
> problem even if the actual amount of memory is much smaller.
>=20
> The main point is that I wouldn't want a time bomb that
> will silently fail when somebody happens to boot on such
> a machine.  Whether that's avoided by a "miraculous" bit,
> throwing away problem pages at boot-time, avoiding task
> allocation at specific addresses, etc.,  is secondary.

I see.
No use to make it too much complicated.
There is always the option CONFIG_DEBUG_SPINLOCK.

On our no-more-than-512-Gbyte-machine, this small stuff
"saved my life" twice.
I just wanted to share it...

Regards,

Zolt=E1n
