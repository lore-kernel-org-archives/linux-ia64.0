From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Fri, 20 Dec 2002 08:23:00 +0000
Subject: Re: [Linux-ia64] Can't boot in SMP with kernel 2.5.50 ia64
Message-Id: <marc-linux-ia64-105590709805627@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805616@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805616@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger writes:
 > >>>>> On Thu, 19 Dec 2002 08:53:06 +0100 (NFT), Xavier Bru  <Xavier.Bru@=
bull.net> said:
 >=20
 >   Xavier> Hello,
 >=20
 >   Xavier> Booting 2.5.50 with David's patch, it seems we can't boot in
 >   Xavier> SMP on an ia64 machine. We get the message: SMP mode
 >   Xavier> deactivated.  Problem is due to smp_prepare_cpus() declaring
 >   Xavier> max_cpus as "unsigned int" and testing against the -1 value.
 >   Xavier> Problem was not seen in 2.5.45 because max_cpus was
 >   Xavier> initialized to UINT_MAX.
 >=20
 > I think the test in smp_prepare_cpus() is bogus.  I changed it to test
 > just against 0 (as is done in the x86 version of smpboot.c).
 >=20
 > 	--david

Hi David,
Thanks for answering my mail.
I just changed to "int" because I saw that max_cpus can be modified at=20
boot time (maxcpus=3D...), and get_option() provides an int.
I think this is why test was done against a negative or null value.

"Joyeux Noel et Bonne Annee a tous".

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


