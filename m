From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 11 May 2005 06:51:18 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <Pine.LNX.4.58.0505102347090.19298@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 10 May 2005, colin ngam wrote:

> >How do I make the function return the correct result?
> This is the correct result - with respect to which node the
> bus/device/function is directly connected.  Either than using this
> function in pcibus_to_cpumask(), what other purpose is this routine
> targeted?  I assume you want the node id for memory placement?  If that
> is the case it may return the wrong node id.  If you expect this node id
> to have cpus(to feed the result to get pcibus_to_cpumask()), it may
> return the wrong node id.

It needs to return a node id that the system knows about. The zonelist
for the node will take care of memory placement.

> There is always a node associated with the device - the issue is that
> the node may not have cpu but has memory, or may not have both memory
> and cpu.  I am a little bit confused about your comment above and the
> usage of pcibus_to_cpumask().  Are you using sn_pcibus_to_node() to
> target memory placement and pcibus_to_cpumask() to target interrupt?

pcibus_to_node is currently only used to target memory placement. It can
return -1 for unknow or any node id that the page allocator knows about.

