From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 25 Mar 2008 19:25:04 +0000
Subject: RE: [11/14] vcompound: Fallbacks for order 1 stack allocations on
Message-Id: <Pine.LNX.4.64.0803251223470.17521@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080321061726.782068299@sgi.com> <20080321.002502.223136918.davem@davemloft.net>
 <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
 <20080321.145712.198736315.davem@davemloft.net>
 <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
 <1FE6DD409037234FAB833C420AA843ECE5B84D@orsmsx424.amr.corp.intel.com>
 <Pine.LNX.4.64.0803251036410.15870@schroedinger.engr.sgi.com>
 <1FE6DD409037234FAB833C420AA843ECE9DDFA@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9DDFA@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 25 Mar 2008, Luck, Tony wrote:

> dtr[1] : maps an area of region 7 that spans kernel stack
>          page size is kernel granule size (default 16M).
>          This mapping needs to be reset on a context switch
>          where we move to a stack in a different granule.

Interesting.... Never realized we were doing these tricks with DTR.

