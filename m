From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Apr 2003 21:14:05 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705427@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 04 Apr 2003 10:13:25 -0500, Jes Sorensen <jes@wildopensource.com> said:
  Jes> The first example I sent out was clearly bogus, please ignore
  Jes> it. I am still pondering the second one. Jack pointed out in
  Jes> private email that the release semantics of setting a volatible
  Jes> variable should take care of it, but I am still trying to grasp
  Jes> it.

In your example:

cpu1()
{
   spin_lock(&bleh);
   *a = foo;
   spin_unlock(&bleh);
   *b = bar;
}

cpu2()
{
   if (*b = bar)
      boink(*a);
}

*a is guaranteed to have the value "foo" when *b observes bar.
spin_unlock() has release semantics and that ensures that all
subsequent (in program order) memory operations are observed after the
store with release semantics.

	--david

