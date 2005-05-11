From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 11 May 2005 01:34:47 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <Pine.LNX.4.58.0505101831140.17717@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 10 May 2005, colin ngam wrote:

> >+int sn_pcibus_to_node(struct pci_bus *bus)
> >+{
> >+	return nasid_to_cnodeid(NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base));
> >
> >
> The cnodeid returned by the above function can be a node id:
>     1.  With memory but no cpus - Headless Nodes.
>     2.  With no memory and no cpus - IO Nodes.

How do I make the function return the correct result?

> pcibus_to_cpumask() can return 0 if the node is an ionode - TIO or
> Headless Node(node with no CPUs but has memory).

How can I determine that? A return value of 0 would mean that the block
i/o layer would allocate the control structures on node 0. The correct
result is -1 if there is no node associated with the device.
