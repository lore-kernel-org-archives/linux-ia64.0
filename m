From: Andreas Schwab <schwab@suse.de>
Date: Thu, 28 Jun 2001 16:39:41 +0000
Subject: Re: [Linux-ia64] Linux 2.4.4 boot hangs at "SCSI(0): Verifying chip ..."
Message-Id: <marc-linux-ia64-105590693005801@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005797@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005797@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Stephane Eranian <eranian@frankl.hpl.hp.com> writes:

|> On Thu, Jun 28, 2001 at 03:37:46PM +0200, Verkist, Bruno wrote:
|> > Hello,
|> >=20
|> > Booting my Lion Qual with SuSE 7.2a RC1 (2.4.4-SMP) sporadically hangs=
 at
|> > scsi(0): verifying chip ...
|> >=20
|> I wonder if you have the 64bit support enabled for the QLA in the setup.=
=20
|> You must make sure that it is enabled. Press F2 and check it out.

That should not make any difference.  The QLA driver now enables that
automatically.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

