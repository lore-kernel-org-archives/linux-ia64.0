From: Alex Williamson <alex_williamson@hp.com>
Date: Tue, 01 Apr 2003 16:12:27 +0000
Subject: [Linux-ia64] Re: [chad_smith@hp.com: RE: [peter@chubb.wattle.id.au: Re: [Linux-ia64]
Message-Id: <marc-linux-ia64-105590723705375@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

   Warning, the commands given by Willy clears _everything_ in
nvram, this is not recommended.  Here's how you clear just the logs:

To clear the forward progress log:

cli>ipmi 28 C7 43 4C 52
 00                                                .

Clearing the system event log is a 2 step process, first get a
reservation ID:

cli>ipmi 28 42
 00 XX YY                                          ...
    ^^^^^ =3D reservation ID

Then issue the clear:

cli>ipmi 28 47 XX YY 43 4c 52 aa
               ^^^^^ =3D reservation ID from above
 00 01                                             ..

cli>se
SEL is empty.
cli>fpl
FPL is empty.

Thanks,

	Alex


Matthew Wilcox wrote:
>=20
> ----- Forwarded message from "SMITH,CHAD (HP-FtCollins,ex1)" <chad_smith@=
hp.com> -----
>=20
> From: "SMITH,CHAD (HP-FtCollins,ex1)" <chad_smith@hp.com>
> To: 'Matthew Wilcox' <willy@debian.org>
> Subject: RE: [peter@chubb.wattle.id.au: Re: [Linux-ia64] Another stupid lo
>         gging question...]
> Date: Tue, 1 Apr 2003 07:21:24 -0800
> X-Mailer: Internet Mail Service (5.5.2655.55)
>=20
>  Hey Willy,
>=20
>    Here's the magic:
>=20
> 1) Power off system
> 2) Enter CLI -  [ESC],(
> 3) Type: ipmi c8 03 00 05 00
> 4) Type: ipmi c8 03 13 05 1e
> 5) Exit CLI (or use it to power on system)
> 6) Power on system
>=20
> This will clear all the EFI, SAL, BMC, and Console Tokens from both the
> NVRam and BMC so they get reinitialized.
>=20
> I'll try writing up a simple html howto for translation of IPMI commands
> into something useful because as far as I'm concerned, using the IPMI spec
> is rocket science.
>=20
> Chad
>=20
> -----Original Message-----
> From: Matthew Wilcox [mailto:willy@debian.org]
> Sent: Monday, March 31, 2003 7:39 PM
> To: Chad Smith
> Subject: [peter@chubb.wattle.id.au: Re: [Linux-ia64] Another stupid
> logging question...]
>=20
> ----- Forwarded message from Peter Chubb <peter@chubb.wattle.id.au> -----
>=20
> From: Peter Chubb <peter@chubb.wattle.id.au>
> Date: Tue, 1 Apr 2003 12:06:37 +1000
> To: Matthew Wilcox <willy@debian.org>
> Cc: Peter Chubb <peter@chubb.wattle.id.au>,
>     linux-ia64@linuxia64.org,
>     gelato-technical@gelato.unsw.edu.au
> Subject: Re: [Linux-ia64] Another stupid logging question...
> In-Reply-To: <20030401010156.GW29376@parcelfarce.linux.theplanet.co.uk>
> X-Mailer: VM 7.07 under 21.4 (patch 10) "Military Intelligence" XEmacs Lu=
cid
> Comments: Hyperbole mail buttons accepted, v04.18.
> X-Face:
> GgFg(Z>fx((4\32hvXq<)|jndSniCH~~$D)Ka:P@e@JR1P%Vr}EwUdfwf-4j\rUs#JR{'h#
>=20
> !]])6%Jh~b$VA|ALhnpPiHu[-x~@<"@Iv&|%R)Fq[[,(&Z'O)Q)xCqe1\M[F8#9l8~}#u$S$R=
m`S
> 9%
>  \'T@`:&8>Sb*c5d'=EDYI&GF`+t[LfDH=3D"MP5rwOO]w>ALi7'=3DQJHz&y&C&TE_3j!
>=20
> >>>>> "Matthew" =3D Matthew Wilcox <willy@debian.org> writes:
>=20
> Matthew> On Tue, Apr 01, 2003 at 10:09:02AM +1000, Peter Chubb wrote:
> >> Every time I boot my ZX2000, (which as it's a kernel development
> >> system is often) I get a little message that says the BMC event log
> >> is full.  I can read the log --- it's not very interesting --- but
> >> how do I clear it (and the forward progress log, too)?
>=20
> Matthew> You need to use IPMI to do it.  I forget which commands do
> Matthew> that..
>=20
> That's what I was afraid of...  The CLI interface to IPMI is not
> exactly user-friendly.  And because it's not easy to see what one is
> doing (magic numebrs everywhere!), it's possible to screw up badly.
>=20
> I think that this means I do
> cli> ipmi 0A 47 0 0 43 4C 52 AA
>=20
> is that right ?  I *think* this is the code to clear the system event
> log; whether that also clears the BMC event log and the forward
> progress log I don't know.   The latter two logs are not mentioned in
> the IPMI 1.5 spec.
>=20
> The syntax is:
>     ipmi netfnlun cmd data
>=20
> (BMC cli help)
>=20
> In this case, the netfn is `storage' (appendix G) which translates to
> 0x0A (table 5.1 of the IPMI 1.5 spec), and the LUN is zero (low two
> bits of netfnlun).  The CMD is `CLR SEL' (0x47 appendix G of IPMI
> spec) and the data is 0 0 43 4C 52 AA (section 25.9)
>=20
> Peter C
>=20
> ----- End forwarded message -----
>=20
> --
> "It's not Hollywood.  War is real, war is primarily not about defeat or
> victory, it is about death.  I've seen thousands and thousands of dead
> bodies.
> Do you think I want to have an academic debate on this subject?" -- Robert
> Fisk
>=20
> ----- End forwarded message -----
>=20
> --
> "It's not Hollywood.  War is real, war is primarily not about defeat or
> victory, it is about death.  I've seen thousands and thousands of dead bo=
dies.
> Do you think I want to have an academic debate on this subject?" -- Rober=
t Fisk
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--
Alex Williamson                             HP Linux & Open Source Lab

