From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Mon, 18 Feb 2008 13:47:56 +0000
Subject: Re: RSE Behavior on Interruptions
Message-Id: <20080218134756.GA9673@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <47B988DA.3020807@bull.net>
In-Reply-To: <47B988DA.3020807@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Zoltan,

The architecture defines that only mandatory (=DEmand) RSE accesses can
fault, background RSE activity never raises faults - see SDM II.6.6.

(In any case, current processors don't implement eager mode, so RSE
accesses are only done on demand anyway...)

Matt


On Mon, Feb 18, 2008 at 02:32:10PM +0100, Zoltan Menyhart wrote:
> Let's assume a user program just has been interrupted.
> The RSE can continue spilling/filling registers on behalf of the=20
> interrupted user.
> Let's assume the RSE engine touches a swapped out page.
> As PSR.ic is 0, the page fault cannot be captured correctly.
>=20
> Can this scenario happen to the current Linux kernel implementation?
>=20
> Thanks,
>=20
> Zoltan Menyhart
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
