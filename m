From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Jan 2005 20:00:53 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <16861.39157.398465.259829@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 6 Jan 2005 19:47:33 +0000, Matthew Wilcox <matthew@wil.cx> said:

  >> Well, it probably should move outside of the ia64 tree anyhow.
  >> The way x86_64 includes swiotlb.c at the moment is just
  >> absolutely gross.

  Matthew> kernel/swiotlb.c would make most sense, I guess?

lib/swiotlb.c, actually.

	--david
