From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 May 2004 16:55:44 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <16545.1424.69361.799582@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 May 2004 21:32:00 +1000, Keith Owens <kaos@sgi.com> said:

  >>  Can you try what's in the current bk repository?  It closely
  >> follows your patch, apart from some naming and from switching the
  >> asm files to actually use ".save rp, r0".

  Keith> I don't have bk access.  Where's the patch?

At:

 http://kernel.org/pub/linux/kernel/ports/ia64/v2.6/testing/cset/index.html

You'll definitely want:

  ChangeSet 2004/05/10 22:48:57-07:00, davidm @ tiger.hpl.hp.com

There is also a tiny fix for unwind.c in:

  ChangeSet 2004/05/10 23:44:48-07:00, davidm @ tiger.hpl.hp.com

but that one isn't strictly needed (it mainly corrects a prototype to
avoid a compiler-warning).

	--david
