From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 15 Mar 2002 03:56:07 +0000
Subject: [Linux-ia64] Re: compiler version for kernel builds
Message-Id: <marc-linux-ia64-105590701905292@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 15:46:04 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> David, which compiler version do you use for kernel builds
  Jesse> these days?

I usually use 3.0, though I try to remember to test with 2.96 from
time to time.  I haven't had much luck with 3.1 yet: it builds a
working kernel for the simulator, but the kernel for the real machine
dies early on.  Haven't had time yet to investigate.

  Jesse> Also, is there a document somewhere that
  Jesse> describes building that version as a cross compiler?  Last
  Jesse> time I tried building 3.0.2 as an x86 hosted ia64 cross
  Jesse> compiler, I ran into some trouble.

We posted something on this list a while ago (search for "recipe" or
something like that).  We haven't built a cross-compiler recently, so
the recipe may not be perfectly accurate anymore.

	--david


