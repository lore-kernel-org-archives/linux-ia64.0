From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 May 2004 00:19:37 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <16537.33945.102180.589912@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 06 May 2004 10:08:21 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> I would rather keep the ability to .save rp,r0 and fix the
  Keith> unwinder to cope, even if it needs a kludge.  After all, a
  Keith> great luminary said that .save rp,r0 was the correct fix back
  Keith> in March 2003.

  Keith> http://marc.theaimsgroup.com/?l=linux-ia64&m5590709806090&w=2

I'd have preferred if there had been a simple and clean fix to the
existing unwinder that supports .save rp,r0, but I haven't seen/found
something acceptable yet.  Also, the kernel has always been using the
non-race-free version for historical reasons.  In other words: when
the new unwinder goes in, we need to go through the code and replace
".save rp, r4; mov r4=r0" with ".save rp, r0" anyhow.
start_kernel_thread() is special because we can tweak it easily enough
to make the ".save rp, r4" work in a race-free manner.

	--david
