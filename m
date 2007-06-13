From: Jes Sorensen <jes@sgi.com>
Date: Wed, 13 Jun 2007 11:01:50 +0000
Subject: Re: [IA64] Set default page size to 64k
Message-Id: <yq0bqfk15k1.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Tony> But I've been thinking of switching over to 64K pages for a
Tony> while.  As you say ia64 systems tend to have a large amount of
Tony> memory ... and everyone's idea of "large" when talking about
Tony> memory has been gradually increasing over the years (choice for
Tony> laptops is now 1G or 2G!).  It would seem silly to provision an
Tony> ia64 box with less than 16G of memory today.

Maybe we should ask for some benchmarks before making this change?
IMHO 64KB seems a lot, but maybe it isn't when it comes down to it. I
guess it depends a lot on the actual application users are trying to
run.

I think there are still broken user apps out there that hard code the
page size, but then thats not really our problem since we've had
getpagesize() in glibc for eons.

Cheers,
Jes
