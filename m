From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 17:17:11 +0000
Subject: Re: [PATCH] split contig and discontig functions
Message-Id: <marc-linux-ia64-106433787001281@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106428053212055@msgid-missing>
In-Reply-To: <marc-linux-ia64-106428053212055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Jesse> Oops, I forgot to make meminit.h protect against multiple
  Jesse> inclusion and there are some other minor formatting stuff
  Jesse> that I missed.  I'll post another patch shortly.

Don't worry about it.  I already checked in a variant of your patch that
fixes those things.  Should be in the bk repo shortly (sometime today).

	--david
