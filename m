From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Dec 2004 18:23:11 +0000
Subject: Re: Should we relax in udelay()?
Message-Id: <16833.53903.40450.330087@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041214193112.GT27199@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041214193112.GT27199@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 14 Dec 2004 19:31:12 +0000, Matthew Wilcox <matthew@wil.cx> said:

  Matthew> Would the following patch be a good idea?

I think so.

  Matthew> Obviously, this is a busy-loop, but does itc tick correctly
  Matthew> while we're relaxing?

Yes.

	--david
