From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 Feb 2004 21:55:34 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16446.27478.605433.219419@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Feb 2004 21:37:04 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> - Don't print the SAL platform features line if there's no features.

How about printing "none" or something like that instead?

	--david
