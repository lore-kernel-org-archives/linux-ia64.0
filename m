From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Nov 2003 19:15:01 +0000
Subject: Re: [PATCH] - kernel profiler & spinlock_contention
Message-Id: <marc-linux-ia64-106987427702266@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106986108616188@msgid-missing>
In-Reply-To: <marc-linux-ia64-106986108616188@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Nov 2003 13:02:30 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> However, if your new tools allows me to determine the caller
  Jack> of spinlock_contention (I'm guessing that it does), that is
  Jack> even better!!

Absolutely.  Best of all, it requires absolutely no kernel modes.
All it requires is a recent 2.6 kernel and an Itanium 2 CPU
(sorry, Merced is out for this feature).

  Jack> If a prerelease version of the tools is available, I'll be
  Jack> happy to try it on our system

I'll see what I can do.

	--david
