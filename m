From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Nov 2003 22:31:42 +0000
Subject: Re: [PATCH] enable platform dependent MCA handling
Message-Id: <marc-linux-ia64-106859111711500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106850974125144@msgid-missing>
In-Reply-To: <marc-linux-ia64-106850974125144@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Nov 2003 16:17:11 +0900, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> said:

  Hidetoshi> I think it is more flexible that the plan that generic
  Hidetoshi> kernel have all the platform specific code and have
  Hidetoshi> choices at run time, Keith said.

That's what machvec gives you.  The only question is whether some
vendors will have to split up DIG into something more finer-grained.

  Hidetoshi> ...Are there any plans to implement
  Hidetoshi> "platform_cpei_handler (for CPEI)"?  David?

I'm not, but adding new (well-defined) machvec entries is fine (within
reason).

	--david
