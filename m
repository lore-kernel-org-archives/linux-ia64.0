From: Xavier Bru <Xavier.Bru@bull.net>
Date: Tue, 09 Sep 2003 09:06:54 +0000
Subject: Re: kdb v4.3 for linux-2.6.0-test4
Message-Id: <marc-linux-ia64-106309887302942@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Hi jim,

I also updated kdb v4.3 to linux-2.6.0-test4 ia64 (No major
enhancement) on:

      http://www.bullfreeware.com/linux/kdb=20

83519	Sep  9 10:27 kdb-v4.3-2.6.0t4-common-b0.bz2
111564  Sep  9 10:28 kdb-v4.3-2.6.0t4-ia64-b0.bz2

and I also hope we can merge some day :-)

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


Jim Houston writes:
 > Hi Keith, Xavier, Everyone,
 >=20
 > I have updated my patch for kdb on i386 for linux-2.6.0-test4.
 > It is available here:
 >=20
 > 	 http://www.ccur.com/realtime/oss
 >=20
 > This version is based SGI's kdb-v4.3-2.4.22.
 >=20
 > This version fixes a couple of bugs in my earlier patch.  I was not
 > clearing the returned symbol in kdbnearsym() when no matching symbol
 > was found. This resulted in error messages on stack trace backs.
 > I also fixed the pid lookup in the btp command.  It is now thread
 > aware.
 >=20
 > I just did a quick merge this time.  I still hope to sort out the
 > differences between my patch and Xavier's patch for ia64.
 >=20
 > Jim Houston - Concurrent Computer Corp.
 >=20
 >=20
 >=20
 >=20
