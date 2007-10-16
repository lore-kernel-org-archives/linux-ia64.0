From: Russ Anderson <rja@sgi.com>
Date: Tue, 16 Oct 2007 15:09:49 +0000
Subject: Re: PAL_PROC_SET_FEATURES documentation
Message-Id: <20071016150948.GA15834@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071016083414.GA28569@cse.unsw.EDU.AU>
In-Reply-To: <20071016083414.GA28569@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Oct 16, 2007 at 06:34:14PM +1000, Matthew Chapman wrote:
> Where would I find documentation on the Itanium 2 specific flags to
> PAL_PROC_SET_FEATURES?

"Intel=AE Itanium=AE 2 Processors Firmware Guide", though I don't see it
on the Intel website.  Don't recall if the document is restricted.
=20
> Linux arch/ia64/kernel/setup.c seems to enable bit 0x80, but there is no
> explanatory comment attached.

I assume you are refering to this code.

--------------------------------------
#ifdef CONFIG_MCKINLEY
        {
#               define FEATURE_SET 16
                struct ia64_pal_retval iprv;

                if (cpu_info->family =3D 0x1f) {
                        PAL_CALL_PHYS(iprv, PAL_PROC_GET_FEATURES, 0, FEATU=
RE_SET, 0);
                        if ((iprv.status =3D 0) && (iprv.v0 & 0x80) && (ipr=
v.v2 & 0x80))
                                PAL_CALL_PHYS(iprv, PAL_PROC_SET_FEATURES,
                                              (iprv.v1 | 0x80), FEATURE_SET=
, 0);
                }
        }
#endif
--------------------------------------

Note that it is setting bit 7 (0x80) in feature set 16 (not feature set 0).

> The Itanium 2 microarchitecture manual [1] says that early deferral of
> speculative memory ops (bypassing VHPT walker) can be enabled via
> PAL_PROC_SET_FEATURES, but as far as I can see does not specify anywhere
> which is the appropriate bit...
>=20
> Also, is it true that early deferral only happens with psr.ic=3D0, as
> per Table 5-2?  What is the motivation for that?
>=20
> Matt
>=20
> [1] i.e. http://download.intel.com/design/Itanium2/manuals/25111003.pdf
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Russ Anderson  RAS group  SGI  rja@sgi.com
