From: Rik van Riel <riel@redhat.com>
Date: Wed, 20 Jul 2016 16:22:07 +0000
Subject: Re: [PATCH v3 00/11] mm: Hardened usercopy
Message-Id: <1469031727.30053.71.camel@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-2eVAnQvIdZJKNQESaf+x"
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <063D6719AE5E284EB5DD2968C1650D6D5F4FD6A3@AcuExch.aculab.com>
 <CAGXu5j+QH8Fdk7p6bZV_yMv1puHRxZRu5z45+tKrmLyGBTymFw@mail.gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D5F4FEA62@AcuExch.aculab.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4FEA62@AcuExch.aculab.com>
To: David Laight <David.Laight@ACULAB.COM>, 'Kees Cook' <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Daniel Micay <danielmicay@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>


--=-2eVAnQvIdZJKNQESaf+x
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-07-20 at 16:02 +0000, David Laight wrote:
> From: Kees Cook
> > Sent: 20 July 2016 16:32
> ...
> > Yup: that's exactly what it's doing: walking up the stack. :)
>=20
> Remind me to make sure all our customers run kernels with it
> disabled.

You want a single copy_from_user to write to data in
multiple stack frames?

--=20

All Rights Reversed.
--=-2eVAnQvIdZJKNQESaf+x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXj6UwAAoJEM553pKExN6DcNgH/1kx7TO66ZDBo8zg805rrltm
6J3na8WIOvwfybajpvb1IGnKVz+ZICW2dgKnTbH7tPjs/QZ0hwA912DVq5eEFVSb
wOe8fKr4aqifq73uFMkkLXR8U0VY5XDGmjiooLWwQGLxV0ALk/8Rga9emhvECztB
s1b9mwxTjE2rViwdws2ovIqW+A14DSUhRp/ctKSJZ72jTISHelfrwe0UAHabsgpr
rCTFWFwx0EiORx/kITLjrx24MsCkxJ8utZgER3bEqLoRSJqFFtBr4mVuM1SloSLE
EqrQPTkqbkvY7IbTpzkIexkA1XGwiE/iE9t+ZnHwr04Th2NFc2l6W1wbgzcJQY0=
=Vh63
-----END PGP SIGNATURE-----

--=-2eVAnQvIdZJKNQESaf+x--

