From: Xavier Bru <Xavier.Bru@bull.net>
Date: Fri, 05 Sep 2003 09:19:13 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106275665128390@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Jesse Barnes writes:
 > On Thu, Sep 04, 2003 at 12:06:46PM -0700, Luck, Tony wrote:
 > > What are the remaining issues with sparse memory within a node?
 > > CONFIG_VIRTUAL_MEM_MAP should be able to cope with this without
 > > wasting memory on "struct page" for non-existent pages in the holes.
 >=20
 > Yeah, that's what we're using the latest discontig patches.
 >=20
 > > Presumably there are some bootmem bitmap size issues if the gaps
 > > within nodes are too huge.  But a few GB shouldn't be a problem (with
 > > a 16K page size, each GB of memory/hole only takes 8K of bitmap).
 >=20
 > Right, until we get really huge holes, that'll be ok, and there are
 > already some optimizations to keep track of the last place a successful
 > bootmem allocation came from so that you don't keep walking through the
 > holes, which helped zx1 boots.

This allows supporting our platform without specific modifications.
=20
>=20
 > > Is there anything else that blows up?
 >=20
 > Not that I know of...
 >=20
 > > If not, then could we just drop the printk altogether?
 >=20
 > Sure, sounds good to me.

About code cleaning, it seems that the IA64_NODESIZE_*=20
options are still present in Kconfig but no more used, at least for
DIG platforms.

Thanks again for taking in account our problem.
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
