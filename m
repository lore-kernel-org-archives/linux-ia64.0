From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jul 2004 23:48:48 +0000
Subject: Re: Timer patches (nsec support + fastcalls for gettod/clock_gettime
Message-Id: <16627.9056.572246.317538@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 Jul 2004 16:40:13 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> Ok. Will do all of what you said that I did not quote. Do
  Christoph> I really need to save predicates? There are no docs on
  Christoph> saving pr and the old gettimeofday assembly routine did
  Christoph> not save the predicates and worked without a problem.

Preserved registers _always_ need to be preserved by fsys-handlers.
If you avoid using preserved predicates, there is no need to save
them.  See the software conventions & runtime architecture guide for
details (as far as predicate registers go, p1-p5 and p16-p63 are
"preserved").

  Christoph> I was not able to find the patch but I will talk to
  Christoph> George about this.  However, gettimeofday with a timeval
  Christoph> is an established standard. George's current patches on
  Christoph> sf.net use clock_gettime to retrieve higher precision
  Christoph> timer values.

The kernel-internal gettimeofday() can return anything it wants (as
long as all platforms do it consistently.  As to whether or not that's
a good idea, i don't really care (but I do not think it's reasonable
or necessary to have two platform routines with the only difference
being whether they return timeval or timespec).

  Christoph> What could be done is to change do_gettimeofday to use a
  Christoph> timespec and then have sys_gettimeofday to the proper
  Christoph> scaling. Is that what you were thinking?

Yup, that's what I meant.

  Christoph> But do_gettimeofday is used a gazillion times all over
  Christoph> the linux sources and changing that would result in a
  Christoph> huge patch that might not be acceptable either.

That can be OK, if there is agreement that it's The Right Thing.
Hence it's definitely something that should be done in coordination
with George and lkml in general (and it also needs to be done
separately from the ia64-specific changes; figuring out how to break
the patch up is one thing we'll need to sort out eventually).

	--david
