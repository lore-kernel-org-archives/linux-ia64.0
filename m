From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 25 Jan 2005 15:27:49 +0000
Subject: Re: Questionable code in pci_sal_read
Message-Id: <20050125152749.GW31455@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <jek6q1o7p2.fsf@sykes.suse.de>
In-Reply-To: <jek6q1o7p2.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Jan 25, 2005 at 04:21:45PM +0100, Andreas Schwab wrote:
> These are the first few lines in pci_sal_read:
>=20
> 	if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 4095))
> 		return -EINVAL;

This line is incorrect, the check should be against (seg > 65535).
Good catch.

> 	if ((seg | reg) <=3D 255) {
>=20
> When seg <=3D 255 then ((seg | reg) <=3D 255) is equivalent to (reg <=3D =
255).
> But pci_sal_write only rejects (seg > 65535).
>=20
> The lines come from this changeset:
>=20
> http://linux.bkbits.net:8080/linux-2.6/cset%40407c8325V8ZAIQkFDRCUNpu5AXq=
G1g
>=20
> Andreas.
>=20
> --=20
> Andreas Schwab, SuSE Labs, schwab@suse.de
> SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
> Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
> "And now for something completely different."
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
"Next the statesmen will invent cheap lies, putting the blame upon=20
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince=20
himself that the war is just, and will thank God for the better sleep=20
he enjoys after this process of grotesque self-deception." -- Mark Twain
