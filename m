From: Xavier Bru <xavier.bru@bull.net>
Date: Fri, 03 Sep 2004 15:44:40 +0000
Subject: Re: HCDP concerns
Message-Id: <41389168.7090507@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4135A3A7.9000706@bull.net>
In-Reply-To: <4135A3A7.9000706@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:

>
>
>Let me restate this to see if I understand what you need:
>
>I think you have ports at 0x3f8 and 0x2f8.  The desired naming
>is 0x3f8 =3D ttyS0 and 0x2f8 =3D ttyS1.
>
>With CONFIG_EFI_PCDP=3Dn, you should get the desired naming, and
>"console=3DttyS0" or "console=3DttyS1" should both work and go to
>the correct ports (but the output won't start until the serial
>driver initializes).
> =20
>
Yes, but I also want to be able to have the boot traces when system does=20
not boot, and also have an
early kdb prompt.

>With CONFIG_EFI_PCDP=3Dy, the first port in the HCDP becomes ttyS0.
>(This is a bug and I'll try to fix it soon.)  "console=3DttyS0"
>should work, the output should start early, and it should go to
>the first device in the HCDP.  "console=3DttyS1" should also work,
>but the output won't start until later, and it should go to the
>other port (the one that is NOT described first in the HCDP).
> =20
>
yes, but currently our 1rst (and only one) HCDP entry is 2f8, and=20
console=3DttyS1 gives
also the same serial (2f8). This is why I was looking for the previous=20
ttyS0 semantic (3f8).

>I think what you want is a way to
>	(1) get early output, and
>	(2) specify the port where the output should go
>That's perfectly reasonable, but neither scenario above gives
>you that.
>
>Rather than using the hack of assuming ports at 0x3f8 and 0x2f8,
>I'd like to use this as an excuse to get the cleaner solution
>done.  I'm thinking something like a "console=3Dserial,0x3f8"
>argument to specify the device.  Then we don't have to bind a
>name to the device, so we get rid of the renaming problem.
>And the HCDP/PCDP will become just a default source of the "0x3f8"
>information if it's not on the command line.
>
>Would that solve the problem?
> =20
>
Yes, it sounds good. In our case we keep our H/PCDP describing where is=20
directed the EFI console, that provides the default console for linux,=20
and we still have the possibility to override at boot time to go to=20
another console.
Thanks a lot for looking in deep to my problem.
Xavier

>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> =20
>


--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

