From: tony.luck@intel.com
Date: Thu, 21 Apr 2005 21:55:43 +0000
Subject: Re: ia64 git pull
Message-Id: <200504212155.j3LLtho04949@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
 <Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linus Torvalds <torvalds@osdl.org>
Cc: linux-ia64@vger.kernel.org

Adding linux-kernel to Cc: list, as I'm sure Linus wants to hear from
all maintainers, not just those that hang out on the linux-ia64 list.

>On Thu, 21 Apr 2005, Linus Torvalds wrote:
>Btw, just in case it wasn't obvious anyway: I based pretty much _all_ of
>the git design on three basic goals: performance, distribution and
>integrity checking. Everything else pretty much flows from those three
>things.

>But I really tried to make sure that git ends up not just working as a
>system for me to apply patches, but as a system for me to merge other
>peoples work. And I think technically, git does that merge thing very=20
>well, and it's certainly living up to my expectations.

>However, I kind of knew what my expectations _were_ in the first place,
>and as such the thing is very much designed for what I think I needed to
>have to work with you guys. Making it fit the old workflow was obviously a
>big deal, but I don't know how people really worked on the "other end",
>so...

>In other words, what this digression is leading up to is just me saying
>that if you have feedback on how this whole git thing is working for
>_you_, please don't feel shy. I realize that it's a bit raw and rough
>right now, and people are working on making for better interfaces, but if
>you have some particular worry or issue, don't feel like git was forced
>upon you as a fait accompl=ED, but complain and tell me what your biggest
>problems are.

>I may not be able to do a lot about them (the unmentioned fourth basic
>goal was obviously: simple enough that I could actually implement the dang
>thing), but still..

>So if there's some feature (or _lack_ of one) that really bugs you, speak =

>up.

I can't quite see how to manage multiple "heads" in git.  I notice that in
your tree on kernel.org that .git/HEAD is a symlink to heads/master ...
perhaps that is a clue.

I'd like to have at least two, or perhaps even three "HEADS" active in my
tree at all times.  One would correspond to my old "release" tree ... point=
ing
to changes that I think are ready to go into the Linus tree.  A second would
be the "testing" tree ... ready for Andrew to pull into "-mm", but not ready
for the base. The third (which might only exist in my local tree) would be
for changes that I'm playing around with.

I can see how git can easily do this ... but I don't know how to set up my
public tree so that you and Andrew can pull from the right HEAD.

-Tony
