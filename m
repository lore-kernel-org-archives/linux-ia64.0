From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 22 Mar 2004 19:02:58 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <200403221202.58482.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Monday 22 March 2004 11:56 am, Jens Axboe wrote:
> > -=A0=A0=A0=A0=A0int dma =3D info->dma, dma_error =3D 0;
> > +=A0=A0=A0=A0=A0int dma =3D info->dma, dma_err =3D 0;
>=20
> This is really silly imho, make ia64 generic target cut down on it's
> name space polution instead then.

Yeah, that's fair enough, but I'm not ready to sign up for that.
Maybe someone else more expert than I in the machvecs will.
