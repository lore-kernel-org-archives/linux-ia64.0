From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 May 2004 16:40:58 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <16535.51098.555903.17982@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 04 May 2004 12:07:25 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> David, you wanted rp <- r0 to get a clean termination of the
  Keith> unwind chain.  Without that clean termination, unwind wanders
  Keith> off into nowhere generating garbage.  This has already
  Keith> confused at least two people.

Did you not read the changelog entry where I explained why I chose
this approach?

	--david
