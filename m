From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Nov 2003 17:31:02 +0000
Subject: Re: [PATCH] - kernel profiler & spinlock_contention
Message-Id: <marc-linux-ia64-106986816126454@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106986108616188@msgid-missing>
In-Reply-To: <marc-linux-ia64-106986108616188@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Nov 2003 09:23:10 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> Profiling is more useful if addresses in spinlock_contention
  Jack> were attributed to the caller of spinlock_contention.

Execuse the language, but I'm reading:

	my tools suck so let's make the kernel suck!

Let's defer this discussion until next week, when I had a chance to
release my profiling tool.  I think you'll then agree that it's much
better to leave the code as is.  In fact, we should also have an
out-of-line contention handler for the read/write locks.

	--david
