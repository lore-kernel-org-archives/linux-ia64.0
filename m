From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Apr 2004 16:11:14 +0000
Subject: Re: [PATCH] minor processor.h cleanup
Message-Id: <16529.10530.209591.912411@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404281011.38501.bjorn.helgaas@hp.com>
In-Reply-To: <200404281011.38501.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Apr 2004 08:38:36 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> I don't feel strongly either way.  The comment "Cannot write
  Bjorn> to CRx with PSR.ic=1" preceding the ia64_itr() call just
  Bjorn> wasn't obvious to me and it seemed like a good opportunity
  Bjorn> for someone to screw up when calling ia64_itr().

That's true, but they'll notice _very_ quickly if they miss that
(instant fault...).

Perhaps we should have a higher-level convenience-routine which does
all the psr.ic magic.  That would be fine with me.

	--david

