From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Dec 2007 22:05:15 +0000
Subject: RE: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <617E1C2C70743745A92448908E030B2A031D322A@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> What was the exact reason switching to phython and can we do the same in perl?

It was a shell script (using awk) before it was pythonised. The
motivation was correct functionality when cross-building on a
32-bit host.  Here's the commit:

 http://tinyurl.com/28hmoc

-Tony
