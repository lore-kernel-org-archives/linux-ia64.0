From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Oct 2003 23:31:45 +0000
Subject: Re: [PATCH 2.6.0test5: 2 of 3] MCA/TLB recovery
Message-Id: <marc-linux-ia64-106565591808349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106522368223247@msgid-missing>
In-Reply-To: <marc-linux-ia64-106522368223247@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Oct 2003 15:45:16 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> Really, even for ia64 code?

Yes, Linus was very clear that the bug-fix-only applies to the entire
kernel, including all platform-specific code.

  Jesse> Does that mean all the changes I've recently pushed you will
  Jesse> be dropped?  What about the fix for CONFIG_DISCONTIGMEM +
  Jesse> CONFIG_VIRTUAL_MEM_MAP that I've been working so hard to
  Jesse> clean up?

If it's a bug fix, it should be OK (for some definition of "bug").
But we may have to expend some extra effort to make it _really_ a bug
fix only.

	--david
