From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 07 Apr 2003 22:09:44 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705429@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> *a is guaranteed to have the value "foo" when *b observes bar.
David> spin_unlock() has release semantics and that ensures that all
David> subsequent (in program order) memory operations are observed
David> after the store with release semantics.

Hi David,

Back to getting a sore head from this one ;-(

Thanks for the book reference, I went and read it and then went on to
the Intel IA-64 Architecture Software Developer's Manual, vol #1. I
only have an old version 1.1 dated July 2000, so it's possible that
there is an updated version out with further clarifications.

Quoting section 4.4.7 "Memory Access Ordering", 2nd paragraph, it says
" .... Release data accesses guarantee that all previous data accesses
are made visible prior to being made visible themselves." The way I
understand that, it is possible that a store performed after an st.rel
may become visible prior to the st.rel, like in this example:

  st [r2] = r32
  st.rel [r3] = r33
  st [r4] = r34

In other words we are only guarantied that [r2] is valid when [r3]
appears but have no guarantie that [r4] doesn't show up on the bus
prior to [r3]?

Sorry for continuing to pester you about this one, it's the only
explanation I can find for the problems some people have been seeing
for tty->count getting messed up in some cases (it is always modified
while holding a spin lock).

Cheers,
Jes

