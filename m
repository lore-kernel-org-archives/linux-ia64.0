From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 31 May 2007 02:37:45 +0000
Subject: RE: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0705301657530.3832@schroedinger.engr.sgi.com>
References: <20070522234314.54081817.akpm@linux-foundation.org>
In-Reply-To: <20070522234314.54081817.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>
Cc: David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

> Ahh okay. cscope will do that too.... But all have __exit.

The trick is that one of them *shouldn't* have __exit.  With cscope
you'll have to use the "Find functions calling this function:"
mode to try and find the __init function that is calling an
__exit function.

-Tony
