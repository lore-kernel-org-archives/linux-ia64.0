From: Leonardo Bras <leonardo@linux.ibm.com>
Date: Mon, 10 Jun 2019 15:27:02 +0000
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as kprobe_page_fault()
Message-Id: <8dd6168592437378ff4a7c204e0f2962d002b44f.camel@linux.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-5Zy/vH+sEK4zQeyqr1da"
List-Id: <linux-ia64.vger.kernel.org>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
 <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
In-Reply-To: <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Christophe Leroy <christophe.leroy@c-s.fr>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrey Konovalov <andreyknvl@google.com>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>


--=-5Zy/vH+sEK4zQeyqr1da
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-06-10 at 08:09 +0530, Anshuman Khandual wrote:
> > > +    /*
> > > +     * To be potentially processing a kprobe fault and to be allowed
> > > +     * to call kprobe_running(), we have to be non-preemptible.
> > > +     */
> > > +    if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> > > +        if (kprobe_running() && kprobe_fault_handler(regs, trap))
> >=20
> > don't need an 'if A if B', can do 'if A && B'
>=20
> Which will make it a very lengthy condition check.

Well, is there any problem line-breaking the if condition?

if (A && B && C &&
    D && E )

Also, if it's used only to decide the return value, maybe would be fine
to do somethink like that:

return (A && B && C &&
        D && E );=20

Regards,

--=-5Zy/vH+sEK4zQeyqr1da
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEMdeUgIzgjf6YmUyOlQYWtz9SttQFAlz+dsYACgkQlQYWtz9S
ttTfRQ/7BnCF2Sm8vpCKt6ji0Aq2vGhwsM6ISA+Vx72iI70yBg1jdV88yhko7lp4
xOwZejel20zp4V3f2xXCpyVnjbg0RNSBBHjkSsWJTHPQd+dVYqoLkR98Q8WrV1Q+
o0LxhoGGEpJwQanH1WL/P1t1crvBt4Htbg9wXfdbJGiFKDvsocC/fBuNkbijcGl2
JvLF8LFak6qojcDxLu4xvBIIrEuL60RklTTRwlZyKi3z4hfZUPLuUkpv4BYexDKU
mbJMxgJ/IgrCWmteuPXuVZHgK80UpvJUM6jacPRWdiIDQ0zG2NbJRh8o7WS4ZtaA
mShCl/Y72OZ9INtiP9ZTHItZyksARvwzFalnkyNkpdigr0FgLYy9tjYlD6ex6Z6W
qWrJSWPsUGDvcE5iy0tfRp/Vq03w1YNbofrg0eIo995y3VW8BM4rR72OrFMWeSuM
x7/4o4EvjYwVK9GTJWECK6wNH/+V3DUgMOJk9SFCde5Qdkg2i9Xpl9prxij8YMFc
AUDqw6hStj1Sb/XfJXIwpHflJsfTK2pozWISJInBkyxFnEIpNpQAHUPn1I1l26LQ
pDL47J1Wn/zM1EtAIgDOEATxWPyRqJN4nFniwAVhMslHB44MAS+XY3KPAr24zSM2
+t+VW/uhJw9igsLPPpyhzQa34M6O+tvw/pHV/IrJCm2vzNBdu9E=
=oA4R
-----END PGP SIGNATURE-----

--=-5Zy/vH+sEK4zQeyqr1da--
