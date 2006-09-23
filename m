From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 23 Sep 2006 01:06:03 +0000
Subject: Re: [BUGFIX][PATCH] cpu to node relationship fixup take2 [1/2]
Message-Id: <20060923100603.52db1f5d.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060922152447.42a83860.kamezawa.hiroyu@jp.fujitsu.com>
	<20060922170604.745d662a.akpm@osdl.org>
In-Reply-To: <20060922170604.745d662a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com

On Fri, 22 Sep 2006 17:06:04 -0700
Andrew Morton <akpm@osdl.org> wrote:

> On Fri, 22 Sep 2006 15:24:47 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > I rewrote the whoe patch..
> > 
> 
> Well I don't recall ever having seen a "cpu to node relationship fixup
> take1" and I have generally lost the plot regarding these fixes.
> 
Sorry....I noticed cpu-to-node relation ship should be fixed before onlining.
About subject, I should be more carefull.

> What I have now is:
> 
> cpu-to-node-relationship-fixup-take2.patch
> cpu-to-node-relationship-fixup-map-cpu-to-node.patch
> 
> I shall send those patches in reply to this email.  Please confirm that
> these are correct, sufficient, complete, etc.
> 
will do.

> Do you believe these are needed in 2.6.18.x?
> 
yes, I do, becasue my system panics now at cpu onlining.

Thank you.

-Kame

