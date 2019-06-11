From: Leonardo Bras <leonardo@linux.ibm.com>
Date: Tue, 11 Jun 2019 17:31:12 +0000
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as kprobe_page_fault()
Message-Id: <bec5983d50e37953b3962a6e53fca0a243c7158b.camel@linux.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-+TvBOjv046XEorglXBMQ"
List-Id: <linux-ia64.vger.kernel.org>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
 <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
 <8dd6168592437378ff4a7c204e0f2962d002b44f.camel@linux.ibm.com>
 <7b0a7afd-2776-0d95-19c5-3e15959744eb@arm.com>
In-Reply-To: <7b0a7afd-2776-0d95-19c5-3e15959744eb@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Christophe Leroy <christophe.leroy@c-s.fr>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrey Konovalov <andreyknvl@google.com>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>


--=-+TvBOjv046XEorglXBMQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-06-11 at 10:44 +0530, Anshuman Khandual wrote:
>=20
> On 06/10/2019 08:57 PM, Leonardo Bras wrote:
> > On Mon, 2019-06-10 at 08:09 +0530, Anshuman Khandual wrote:
> > > > > +    /*
> > > > > +     * To be potentially processing a kprobe fault and to be all=
owed
> > > > > +     * to call kprobe_running(), we have to be non-preemptible.
> > > > > +     */
> > > > > +    if (kprobes_built_in() && !preemptible() && !user_mode(regs)=
) {
> > > > > +        if (kprobe_running() && kprobe_fault_handler(regs, trap)=
)
> > > >=20
> > > > don't need an 'if A if B', can do 'if A && B'
> > >=20
> > > Which will make it a very lengthy condition check.
> >=20
> > Well, is there any problem line-breaking the if condition?
> >=20
> > if (A && B && C &&
> >     D && E )
> >=20
> > Also, if it's used only to decide the return value, maybe would be fine
> > to do somethink like that:
> >=20
> > return (A && B && C &&
> >         D && E );=20
>=20
> Got it. But as Dave and Matthew had pointed out earlier, the current x86
> implementation has better readability. Hence will probably stick with it.
>=20
Sure, I agree with them. It's way more readable.

--=-+TvBOjv046XEorglXBMQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEMdeUgIzgjf6YmUyOlQYWtz9SttQFAlz/5WAACgkQlQYWtz9S
ttSg4A/6A45T2BOxIm5qp+PJ+LwF0fbX0ZI762cE3X6nXDk5fJuRrjyQifBfrD0V
IVWSUrnOXqarYOmPT3CxT33rW05vGtDWObX+OI6J/QW6qU7jSOD1Db1ZUHL0W3WL
7B27RA3gNmEMugnjmM+JvtMkf5SwTdk3ZLr2IA22revoOBxOF5b8iICzA0HfaXg6
8lFSegTY8C2nNQipkeSS4d3KiObNEA1TVJUFqhwJ/VA6qYMnOpKD6WR58QCOxFaF
NIP4ln+HJccwleioGnQ+Q7jFGRD8Hb9zqLKNccpN1MfuZdE9OXcbFB5MXVuPyE/h
JVYbITwMXbIxpZe8o6/Yoc875Tz1phA2GeprZlEF3FDbw/tH0tyb6U5o+8UNpOXp
YdrNxy1oJRK6ZzhW0+FqgMJVo/BBh/8OV3r9ECwYxR3o8ELPVFAcyqrx2XEU7E6p
fBWN/cYXuZFizM0/b2yKd3kO/JIemEdz58/aPOTgJevEb996p7JohS8H8/3lm4gu
VcnlAsH9ivKDmkoFzz6JuXWJB19OSohPW8j2p9fqP5LA5snz8o+ehsewTjaVQsPJ
eNlp1HQzVumviM07wrZmXzVc0zoUb3YhWHrUL26xcfvtfDZVQ+gIOCH9baNsgcoe
U0uI1HQuuUreC4L10sgC2qrlYqbWMUmK5uj6T8fjTRaHlzP1UX8=
=i2hD
-----END PGP SIGNATURE-----

--=-+TvBOjv046XEorglXBMQ--
