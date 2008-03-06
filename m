From: Russ Anderson <rja@sgi.com>
Date: Thu, 06 Mar 2008 17:52:08 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <20080306175208.GA12952@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Mar 06, 2008 at 02:14:48PM +0100, Zoltan Menyhart wrote:
> Luck, Tony wrote:
>=20
> Let's see this first:
>=20
> >Obviously entering polling
> >mode puts the responsibility onto SAL to keep track of all
> >the error reports
>=20
> Please have a look at the
> Figure 2-1. Itanium=AE Processor Family Firmware Machine Check Handling M=
odel
> in the Error Handling Guide.
>=20
> This figure shows that the SAL (or the PAL) cannot see the platform
> originated CPEIs, nor the CPU HW originated CMCIs.

Figure 2-1 does show SAL passing up CPEI records to OS, too.
=20
> When you call SAL_GET_STATE_INFO(), the SAL (and the PAL) will read out
> the error status from some HW registers.
>=20
> Therefore the SAL / PAL cannot store error reports.

See section 5.3.2 CMC and CPE Records

  Each processor or physical platform could have multiple valid corrected
  machine check or corrected platform error records. The maximum number of
  these records present in a system depends on the SAL implementation and
  the storage space available on the system. There is no requirement for
  these records to be logged into NVM. The SAL may use an implementation
  specific error record replacement algorithm for overflow situations. The
  OS needs to make an explicit call to the SAL procedure SAL_CLEAR_STATE_IN=
FO
  to clear the CMC and CPE records in order to free up the memory resources
  that may be used for future records.

5.4.1 Corrected Error Event Record

  In response to a CMC/CPE condition, SAL builds and maintains the error
  record for OS retrieval.
=20
> Can the HW (platform or CPU) help to save error reports?
>=20
> A typical "error register set" - whatever it is - saves the first
> error and maintains a "cumulative error" status (usually reset
> by SAL_CLEAR_STATE_INFO()).
>=20
> CPEs / CMCs will be lost unless you (want to) "swallow" them
> quickly enough.

Yes, we want to handle the records as quickly as possible.


--=20
Russ Anderson, OS RAS/Partitioning Project Lead =20
SGI - Silicon Graphics Inc          rja@sgi.com
