From: Mark Brown <broonie@kernel.org>
Date: Tue, 28 Jan 2020 11:58:16 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <20200128115816.GA4689@sirena.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
List-Id: <linux-ia64.vger.kernel.org>
References: <a7ba6d8a-6443-5994-6a34-2824aa9b054b@c-s.fr>
 <144F3894-7934-4EC7-A9F9-C6A84CA08C65@lca.pw>
In-Reply-To: <144F3894-7934-4EC7-A9F9-C6A84CA08C65@lca.pw>
To: Qian Cai <cai@lca.pw>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Anshuman Khandual <Anshuman.Khandual@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 28, 2020 at 02:12:56AM -0500, Qian Cai wrote:
> > On Jan 28, 2020, at 1:13 AM, Christophe Leroy <christophe.leroy@c-s.fr> wrote:

> > ppc32 an indecent / legacy platform ? Are you kidying ?

> > Powerquicc II PRO for instance is fully supported by the
> > manufacturer and widely used in many small networking devices.

> Of course I forgot about embedded devices. The problem is that how
> many developers are actually going to run this debug option on
> embedded devices?

Much fewer if the code isn't upstream than if it is.  This isn't
something that every developer is going to enable all the time but that
doesn't mean it's not useful, it's more for people doing work on the
architectures or on memory management (or who suspect they're running
into a relevant problem), and I'm sure some of the automated testing
people will enable it.  The more barriers there are in place to getting
the testsuite up and running the less likely it is that any of these
groups will run it regularly.

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAl4wIdcACgkQJNaLcl1U
h9Dslgf+KrZOvdjyO1AcLfLIlE2wA+hRmygG3Gh1YQ9wI6n+03XnA4v7f+7zZaQd
9nylNBzkErkupokycsWYhTEFN7o/tfjVGWte16XdQ1QHQE7npjULPGC5NcVVPfyc
qwaW2i5J5TeAuYArz3YCqLvUY6IAJefbxhZbLXTTBnwINIazuBDiAUzsAd/Uy27Y
x0YHtX4gXucyNEepoozxS07544hKbMvjTO0tt7P8egTTGwNHz+Uz6sMfUA/Muri7
hIJbxM03+cRn9ZKlTca/PzsXJN87ZLvWwcB0TGz+xI3Bjx2D2Q7Dn+OROr2O8e0z
WXNLV2W9WAaBOwArY4IHdeORokpCzg==
=j0+e
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
