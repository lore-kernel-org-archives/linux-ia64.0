From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Dec 2007 22:44:34 +0000
Subject: RE: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <617E1C2C70743745A92448908E030B2A031D32BD@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> So somewhere a perl variant has existed.

This mail thread http://tinyurl.com/2vuacw points to the perl
version.  But it doesn't appear to have ever been checked into
the tree (and the mail message says that it also suffers from
the not-working for a 64-bit binary when running on a 32-bit
host issue ... though it claims that it would be easy to fix).

I can't actually see the script because the web server at unsw.edu.au
seems to feel that it should execute the perl script rather than show
me the contents of it :-(

-Tony

P.S. The python version was checked in almost four years ago ... perhaps
it isn't too big of a deal that we are using it.
