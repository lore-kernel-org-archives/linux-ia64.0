From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 Feb 2004 23:02:06 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16447.52334.745711.47910@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 27 Feb 2004 22:42:15 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> I actually can't find a name for the ?: operator in the C
  Matthew> FAQ.

conditional expression?

  Matthew> Great ;-) Now make a decision on how you want SAL version
  Matthew> testing to work and I'll send you a patch.

I'd really prefer sal_revision() combined with a SAL_VERSION() macro.
I can just look at that and intuitively understand what it's doing
(especially given the symmetry with the LINUX_VERSION macros), whereas
with the sal_version_check() function, I have to go look at it's
definition.

Thanks,

	--david
