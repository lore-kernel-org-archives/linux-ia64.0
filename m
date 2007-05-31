From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 31 May 2007 03:19:18 +0000
Subject: RE: BUG: sleeping function called from invalid context at
Message-Id: <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

On Wed, 30 May 2007, Luck, Tony wrote:

> > Ahh okay. cscope will do that too.... But all have __exit.
> 
> The trick is that one of them *shouldn't* have __exit.  With cscope
> you'll have to use the "Find functions calling this function:"
> mode to try and find the __init function that is calling an
> __exit function.

Urgh... Does it have to be that difficult?
