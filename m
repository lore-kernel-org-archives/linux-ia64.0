From: Xavier Bru <Xavier.Bru@bull.net>
Date: Mon, 20 Oct 2003 15:17:29 +0000
Subject: Re: [PATCH] fix topology init take 2
Message-Id: <marc-linux-ia64-106666301506247@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641524132220@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641524132220@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Jesse Barnes writes:
 > Populate topology directories correctly now that NUMA kernels work.
 >=20
 > Jesse
 >=20

Jesse,

Thanks for the patch. Just one question about it:

Are there relevant informations that can be used apart from:
    node*/meminfo
    node*/cpumap

We find some node*/memblk* and cpu/cpu* that are empty directories.

Should they sometimes provide some informations like LID (for cpu*) or=20
physical block addr & length (for memblk) ? I suppose this is part of
the discussion on libnuma & hwgfs ?

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________
