From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 22 Oct 2004 07:30:39 +0000
Subject: Re: Converting ia64 kernel unwinder to lock free code
Message-Id: <16760.46879.296371.725336@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5907.1098419155@kao2.melbourne.sgi.com>
In-Reply-To: <5907.1098419155@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Oct 2004 14:25:55 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Before I start on this task, are there any other plans for
  Keith> the kernel unwinder code?  In the past davidm has hinted at
  Keith> replacing it with libunwind.

I definitely want to do that.  I'm not sure you can make it entirely
lock-free with caching enabled, but libunwind already works such that
if the lock is already taken, it bypasses the cache and hence doesn't
need to acquire the lock.

	--david
