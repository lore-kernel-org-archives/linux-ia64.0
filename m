From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 24 Mar 2004 18:38:49 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <16481.54713.677149.658886@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Mar 2004 11:29:23 -0700, Bjorn Helgaas <bjorn.helgaas@hp.c=
om> said:

  Bjorn> On Tuesday 23 March 2004 11:17 am, Andrew Morton wrote:
  >> > =A0We're getting namespace collisions from the new dma_error(). =A0R=
ename it to
  >> > =A0dma_mapping_error().

  >> Updated ia64 patch:

  Bjorn> I verified that current linux-2.5 BK + this patch builds and boots=
 OK
  Bjorn> (generic_defconfig), FWIW.

I already checked in a slightly modified version of Andrew's patch into
to to-linus-2.5 repo.  The modification was to avoid the needless
inline-function in the machvec_hpzx1.h.

	--david
