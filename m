From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 08 Oct 2003 14:38:08 +0000
Subject: Re: [PATCH] kill dead code from ml_iograph.c
Message-Id: <marc-linux-ia64-106562393203087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451999732536@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451999732536@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sun, Oct 05, 2003 at 12:35:37PM -0400, Jes Sorensen wrote:
> >>>>> "Christoph" =3D Christoph Hellwig <hch@lst.de> writes:
>=20
> Christoph> More IRIX creepism
> Christoph> --- 1.3/arch/ia64/sn/io/sn2/ml_iograph.c	Mon May 19 14:42:20 2=
003
> Christoph> +++ edited/arch/ia64/sn/io/sn2/ml_iograph.c	Fri Aug  8 12:01:4=
0 2003
> Christoph> @@ -268,17 +268,6 @@
>=20
> Was already removed from the internal tree and in the pipeline so
> please nuke it.

What about syncing that magic internal tree more often.  The qu=E6rterly
SN updates are a mess, so if SGI could decide to send one patch per
change in a timely fashion live would be a lot simpler.

