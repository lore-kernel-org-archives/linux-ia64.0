From: Bruno Cornec <Bruno.Cornec@hp.com>
Date: Tue, 22 Jul 2003 13:31:33 +0000
Subject: Re: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105888070401363@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105887789030732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105887789030732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Grant Grundler (iod00d@hp.com) said:

> On Tue, Jul 22, 2003 at 02:32:54PM +0200, Bruno Cornec wrote:
> > On Linux/ia64 when you do cat /proc/kcore, the system just reboots in a=
 couple
> > of seconds (with RHAS 2.1 std kernel, updated kernel - 2.4.18-e.31) or =
even with a=20
> > vanilla 2.4.21 + david's patches.
>=20
> Known behavior.=20

Humm :-) I tend to find that hardly acceptable that people can crash so eas=
ily=20
a system.=20

> David Mosberger tells me Tony Luck changed the support in
> 2.6 such that only valid regions are accessible.=20

I didn't take time to test with a 2.6, but will now that you say it could b=
e useful :-)

> Don't expect it fixed in RHAS
> anytime soon. You might check if Bjorn Helgaas' ia64 patch on top of 2.4.=
21
> fixes the same problem.

Excuse-me I meant Bjorn's patch on top of 2.4.21. And yes it's crashing the=
 same way
with the latest I tried (linux-2.4.21-ia64-030702.diff.bz2).
Of course, being of no help to provide a valid one, I can't cry if you say
it's not easy/possible on 2.4 ;-)

Thanks for your answer,
Bruno.
--=20
Linux Solution Consultant         T=E9l: +33 476 143 278 - Fax: +33 476 146=
 105
HP/Intel Solution Center http://hpintelco.net Hewlett-Packard Grenoble/Fran=
ce
Des infos sur Linux?  http://www.HyPer-Linux.org      http://www.hp.com/lin=
ux
La musique ancienne?  http://www.musique-ancienne.org http://www.medieval.o=
rg
