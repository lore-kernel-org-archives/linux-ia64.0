From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 24 Mar 2004 18:29:23 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <200403241129.23222.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tuesday 23 March 2004 11:17 am, Andrew Morton wrote:
> > =A0We're getting namespace collisions from the new dma_error(). =A0Rena=
me it to
> > =A0dma_mapping_error().
>=20
> Updated ia64 patch:

I verified that current linux-2.5 BK + this patch builds and boots OK
(generic_defconfig), FWIW.
