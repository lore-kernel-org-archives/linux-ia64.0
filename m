From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 24 Apr 2002 10:26:21 +0000
Subject: Re: [Linux-ia64] A start at large file and filesystem support
Message-Id: <marc-linux-ia64-105590701905509@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905504@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905504@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> Good work!  Since this really doesn't touch any ia64 files:
David> will you work directly with the respective maintainers to get
David> this into the official 2.5 tree?

Sure.  I'll need to split off the changes from the IA64 changes, and
the patch currently will crash on systems that don't use 64-bit
addressing (because of the way the page cache works).  I'd like to get
some people who have enormous filesystems and 64-bit machines to give
the patch a go.

Peter> If you're bitkeeper-enabled, you can pull the patch from
Peter> bk://gelato.unsw.edu.au:2022

David> Not sure how others feel about this, but I for one still like
David> to get diff -u-style patches.  It's just so much faster to get
David> a quick idea of what the patch does.

That's why I provided both -- but 1.8M of diffs is a bit much for an
email.  (I had to change the definition of a couple of interface
functions, which meant lots of files have two line changes)

Peter C

