From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 04:44:10 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705776@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 13:38:23 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> When I try a parallel make, make seems to get it's dependencies
  Ian> out of order.

I see the same thing, but it's only for asm-ia64/offsets.h.  After
that, parallel makes work just fine.  I tend to be able to live with
such "minor" build issues for a loooong time, giving others ample
chance to get impatient first... ;-)

	--david

