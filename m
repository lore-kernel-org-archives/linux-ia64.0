From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 May 2003 18:25:29 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 9 May 2003 10:52:25 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> So, is there any consensus on the best path to pursue?  Chris Wedgwood
  Jesse> is working on option #3, and I've got Tony's patch trimmed down to #2
  Jesse> (with one piece missing--ia64_switch_to runtime patching), but none of
  Jesse> these are in either 2.4 or 2.5 yet.  Maybe for 2.4 we should do #2 or
  Jesse> #3 and for 2.5 we could implement #1 with the virtual offsets Tony
  Jesse> mentioned earlier?

I'm not sure.  I got the impression Tony may be looking at the virtual
remapping in region 5.  I haven't heard whether text replication
turned out to be important for 8870, but I'm starting to lean towards
virtual remapping because it is more versatile (can handle both
"strange" physical memory layouts and kernel replication).  This,
coupled with the fact that it doesn't break any of the existing tools
makes it pretty compelling.  Also, my primary objection about making
the kernel model more complicated doesn't hold much water if we move
everything to region 5.

Would there be a downside to this on SGI's machines?

	--david

