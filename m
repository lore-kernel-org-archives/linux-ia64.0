From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 21 Apr 2005 21:24:30 +0000
Subject: Re: ia64 git pull
Message-Id: <Pine.LNX.4.58.0504211411160.2344@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
In-Reply-To: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



On Thu, 21 Apr 2005, Linus Torvalds wrote:
>=20
> Looks good. Merged and pushed out.

Btw, just in case it wasn't obvious anyway: I based pretty much _all_ of
the git design on three basic goals: performance, distribution and
integrity checking. Everything else pretty much flows from those three
things.

But I really tried to make sure that git ends up not just working as a
system for me to apply patches, but as a system for me to merge other
peoples work. And I think technically, git does that merge thing very=20
well, and it's certainly living up to my expectations.

However, I kind of knew what my expectations _were_ in the first place,
and as such the thing is very much designed for what I think I needed to
have to work with you guys. Making it fit the old workflow was obviously a
big deal, but I don't know how people really worked on the "other end",
so...

In other words, what this digression is leading up to is just me saying
that if you have feedback on how this whole git thing is working for
_you_, please don't feel shy. I realize that it's a bit raw and rough
right now, and people are working on making for better interfaces, but if
you have some particular worry or issue, don't feel like git was forced
upon you as a fait accompl=ED, but complain and tell me what your biggest
problems are.

I may not be able to do a lot about them (the unmentioned fourth basic
goal was obviously: simple enough that I could actually implement the dang
thing), but still..

So if there's some feature (or _lack_ of one) that really bugs you, speak=20
up.

		Linus
