From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Fri, 14 Mar 2003 16:03:26 +0000
Subject: Re: [Linux-ia64] poweroff through ACPI does not work on 2.5.60 ia64
Message-Id: <marc-linux-ia64-105590709806098@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805974@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805974@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi David,
It is OK with 2.5.64:

   Power down.
   acpi_power_off called
   hwsleep-0257 [01] acpi_enter_sleep_state: Entering sleep state [S5]

Thanks
Xavier

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


David Mosberger writes:
 > >>>>> On Wed, 5 Mar 2003 19:33:34 +0100 (NFT), Xavier Bru  <Xavier.Bru@b=
ull.net> said:
 >=20
 >   Xavier> Unlike the 2.4.* version that provides poweroff for ia64
 >   Xavier> through ACPI (power state S5), 2.5.60 only provides poweroff
 >   Xavier> for i386 platforms through acpi/sleep.c.  With the following
 >   Xavier> (not so clean :-) patch, I could have it working on
 >   Xavier> 2.5.60. Thanks for providing a cleaner one.
 >=20
 > This code has been restructured for 2.5.64.  Perhaps your patch isn't
 > even needed anymore.  Can you recheck once the ia64 patch for 2.5.64
 > is out?
 >=20
 > Thanks,
 >=20
 > 	--david
 >=20

