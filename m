From: Xavier Bru <Xavier.Bru@bull.net>
Date: Mon, 20 Oct 2003 17:13:26 +0000
Subject: Re: [PATCH] fix topology init take 2
Message-Id: <marc-linux-ia64-106667045916837@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641524132220@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641524132220@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jesse Barnes writes:
 > On Mon, Oct 20, 2003 at 05:17:29PM +0200, Xavier Bru wrote:
 > >=20
 > > Jesse Barnes writes:
 > >  > Populate topology directories correctly now that NUMA kernels work.
 > >  >=20
 > >  > Jesse
 > >  >=20
 > >=20
 > > Jesse,
 > >=20
 > > Thanks for the patch. Just one question about it:
 > >=20
 > > Are there relevant informations that can be used apart from:
 > >     node*/meminfo
 > >     node*/cpumap
 > >=20
 > > We find some node*/memblk* and cpu/cpu* that are empty directories.
 > >=20
 > > Should they sometimes provide some informations like LID (for cpu*) or=
=20
 > > physical block addr & length (for memblk) ? I suppose this is part of
 > > the discussion on libnuma & hwgfs ?
 >=20
 > Those seem like reasonable things to export in those directories, is
 > there anything else that would be nice to have?
 >=20
 > Jesse
. as evoqued earlier some physical location information like a
position in the rack ( acpi ?).
. information on node status (available/not) for future  hot plug,
unless the presence of the node<x> directory provides the information.
. what about infos already present in /proc/cpuinfo, /proc/pal ?=20

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

