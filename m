From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 05 Apr 2004 21:18:13 +0000
Subject: Re: Missing include in hugetlbpage.c
Message-Id: <16497.52501.342129.963079@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jesmfi7cdl.fsf@sykes.suse.de>
In-Reply-To: <jesmfi7cdl.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 05 Apr 2004 18:56:45 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> This has nothing to do with being module or not.
  Andreas> EXPORT_SYMBOL also needs it.

But I don't see any EXPORT_SYMBOL in hugetlbpage.c.  What am I missing?

	--david
