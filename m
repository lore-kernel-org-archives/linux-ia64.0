From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 20:56:46 +0000
Subject: Re: unwabi mismatch in 2.4.X kernels breaks oops call trace (unwind)
Message-Id: <16425.17806.671840.344614@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076374136.10372.3.camel@peas.bobm>
In-Reply-To: <1076374136.10372.3.camel@peas.bobm>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 10 Feb 2004 13:43:10 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> So I assume the right thing to do is to apply the following
  Bjorn> patch to 2.4.

Yes.  Looks like that's a bit that got dropped during the backport
from 2.5.

	--david
