From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Wed, 01 Feb 2012 21:04:07 +0000
Subject: RE: Memory corruption due to word sharing
Message-Id: <A3E67C2071F49C4CBC4F17E6D77CDDD232754151@G4W3299.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb>
 <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
In-Reply-To: <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linus Torvalds <torvalds@linux-foundation.org>, Torvald Riegel <triegel@redhat.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dsterba@suse.cz" <dsterba@suse.cz>, "ptesarik@suse.cz" <ptesarik@suse.cz>, "rguenther@suse.de" <rguenther@suse.de>, "gcc@gcc.gnu.org" <gcc@gcc.gnu.org>

> From: Linus Torvalds
> >
> > We need a proper memory model.
>=20
> Not really.
>=20
> The fact is, the kernel will happily take the memory model of the
> underlying hardware. Trying to impose some compiler description of the
> memory model is actually horribly bad, because it automatically also
> involves compiler synchronization points - which will try to be
> portable and easy to understand, and quite frankly, that will
> automatically result in what is technically known as a "shitload of
> crap".
The C11 memory model potentially adds overhead in only two cases:

1. When current code involves touching a field that wouldn't otherwise be t=
ouched.  There are odd cases in which this measurably slows down code, but =
I think all agree that we need it.  In addition to bitfields, it can affect=
 speculatively promoting a value to a register in a loop, which at least ol=
der versions of gcc also do.

2. When you use atomic operations for racing accesses.  And in that case, i=
f you really want it, you get a lot of control over memory ordering.  Atomi=
c operations that specify "memory_order_relaxed" should only have three kin=
ds of impact:
	- They ensure the access is indivisible.
	- They tell the compiler that the location may be concurrently modified an=
d it should refrain from optimizations that will break if it is.
	- They enforce cache coherence, i.e. single-variable ordering.  This is im=
plicit on most architectures, but requires ld.acq on Itanium.  IIRC, Paul M=
cKenney argued convincingly that this was essential for preserving programm=
er sanity.

>=20
> Now, a strict memory model is fine for portability, and to make it
> simple for programmers. I actually largely approve of the Java memory
> model approach, even if it has been horribly problematic and has some
> serious problems. But it's not something that is acceptable for the
> kernel - we absolutely do *not* want the compiler to introduce some
> memory model, because we are very much working together with whatever
> the hardware memory model is, and we do our own serialization
> primitives.
I think you are somewhat misinterpreting the C11 memory model.  Aside from =
the minor cache coherence issues on one or two architectures, you can still=
 do that, if you like.  But I suspect you can also do better in places.

>=20
> >=A0No vague assumptions with lots of hand-waving.
>=20
> So here's basically what the kernel needs:
>=20
>  - if we don't touch a field, the compiler doesn't touch it.
>=20
>    This is the rule that gcc now violates with bitfields.
And in other more subtle cases.  At least until very recently.

>=20
>    This is a gcc bug. End of story. The "volatile" example proves it -
> anybody who argues otherwise is simply wrong, and is just trying to
> make excuses.
Agreed.

>=20
>  - if we need to touch something only once, or care about something
> that is touched only conditionally, and we actually need to make sure
> that it is touched *only* under that condition, we already go to quite
> extreme lengths to tell the compiler so.
>=20
>    We usually use an access with a "volatile" cast on it or tricks
> like that. Or we do the whole "magic asm that says it modified memory
> to let the compiler know not to try anything clever"
>=20
>  - The kernel IS NOT GOING TO MARK DATA STRUCTURES.
>=20
> Marking data structures is seriously stupid and wrong. It's not the
> *data* that has access rules, it's the *code* that has rules of
> access.
>=20
> The traditional C "volatile" is misdesigned and wrong. We don't
> generally mark data volatile, we really mark *code* volatile - which
> is why our "volatiles" are in the casts, not on the data structures.
>=20
> Stuff that is "volatile" in one context is not volatile in another. If
> you hold a RCU write lock, it may well be entirely stable, and marking
> it volatile is *wrong*, and generating code as if it was volatile is
> pure and utter shit.
>=20
> On the other hand, if you are touching *the*very*same* field while you
> are only read-locked for RCU, it may well be one of those "this has to
> be read by accessing it exactly once".
>=20
> And we do all this correctly in the kernel.  Modulo bugs, of course,
> but the fundamental rule really is: "atomicity or volatility is about
> CODE, not DATA".
The preferred C11 model is clearly to mark data that potentially participat=
es in unprotected concurrent accesses, and then to annotate accesses that r=
equire less care, e.g. because we know they can't occur concurrently with o=
ther accesses.  Maybe this is the wrong approach for the kernel, but to me =
that seems like a safer approach.  We did consider the alternative model, a=
nd tried to ensure that casts to atomic could also work on as many platform=
s as possible, though we can't guarantee that.  (There is currently no spec=
ification for atomic accesses that says "not concurrently accessed".  We've=
 thought about it.  I would argue for adding it if there were important cas=
es in which memory_order_relaxed is demonstrably not close enough.)

>=20
> And no, C11 does *not* do it correctly. The whole "_Atomic" crap is
> exactly the same mistake as "volatile" was. It's wrong. Marking data
> _Atomic is a sure sign that whoever designed it didn't understand
> things.
>=20
> > The only candidate that I see is the C++11/C11 model. =A0Any other
> > suggestions?
>=20
> The C11 model addresses the wrong thing, and addresses it badly.
>=20
> You might as well ignore it as far as the kernel is concerned. I'm
> sure it helps some *other* problem, but it's not the kernel problem.
But it seems to me that the core of the C11 model consists largely of the r=
ules you're asking for.  Even if you continue to use volatile and ignore at=
omic, it seems to me that you're far ahead, though still on needlessly thin=
 ice, with the C11 model.

>=20
> The rules really are very simple, and the kernel already does
> everything to make it easy for the compiler.
>=20
> When we do something that the compiler cannot re-order around, we do
> an asm() and mark it as modifying memory so that the compiler won't
> screw things up. In addition, we will do whatever that the CPU
> requires for memory ordering, and quite frankly, the compiler will
> never have sufficient locking primitives to satisfy us, and there is
> no real point in even trying. If you try to do locking in the
> compiler, you *will* do it wrong.
Which is one reason C11 gives you fine control over atomics that can be use=
d to implement locks.

>=20
> If you add random flags on data structures ("_Atomic" or "volatile" or
> whatever), you *will* do it wrong. It's simply a fundamentally broken
> model.
>=20
> So the *only* memory model we want from the compiler really is: "don't
> write to fields that the source code didn't write to".
>=20
> It's really is that simple.
You clearly also need to say something about adjacent bitfields.  Nor would=
 it be usable outside the kernel, because the programmer needs to understan=
d the esoteric fence semantics etc. on every architecture in order to reall=
y use it.  (It also isn't exactly a language specification, but that's OK h=
ere.)  But again I think the C11 spec implies exactly what you want here.

>=20
> > So, would it be okay to tell the compiler which part of the state is
> > accessed concurrently (ie, locks, atomics, ...)?
>=20
> Seriously, no.
>=20
> See above: it's not the "state" that is accessed concurrently. It's
> the code. If you ever try to mark state, you've already lost. The same
> "state" can be atomic or not depending on context. It's not about the
> state or the data structures, and it never will be.
I think we have no disagreement that in the end it's the access whose prope=
rties you need to specify.  The question is what constitutes the most conve=
nient and robust way to do so.  Clearly we specify other attributes of acce=
sses (length, alignment) using the type, and perhaps override it when neces=
sary.  C11 atomics arguably use the same approach.

Hans

>=20
>                         Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
