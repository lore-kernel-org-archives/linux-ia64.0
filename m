From: Grant Grundler <iod00d@hp.com>
Date: Fri, 27 Feb 2004 02:47:41 +0000
Subject: Re: [Patch] speed up interrupt handling
Message-Id: <20040227024741.GN15022@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 27, 2004 at 01:18:56PM +1100, Peter Chubb wrote:
> 
> Hi David,
>    The attached patch makes enable_irq() disappear from the profile.
> From ~4000 cycles per call, it's gone down to around 260 cycles.

wow! cool!

> I've only tested on UP; however, the iosapic lock is held around all
> the manipulations of the new field.

I think that's a great tradeoff.

> This also incidentally increases the performance of the gigabit
> network driver: it drops fewer packets.

Is this related to NAPI?

I'll assume "the gigabit" card is e1000:
static void e1000_netpoll (struct net_device *dev)
{
	struct e1000_adapter *adapter = dev->priv;
	disable_irq(adapter->pdev->irq);
	e1000_intr (adapter->pdev->irq, dev, NULL);
	enable_irq(adapter->pdev->irq);
}

Ok - this will work great on ia64 with this patch.
pktgen should measurably perform better too.
I'll have to try that.

e1000_intr() will need to handle being called twice for
the same device in case it gets invoked on something
other than the same CPU which normally handles it's IRQ.

Not sure how the net stack schedules the poll call but
it's probably worth trying to make sure only one
CPU touches instance data for a NIC card.
Anyone know how to enforce or verify that?
(or want to pursue the question on linux-net mailing list)

Any comments on how efficient disable_irq/enable_irq()
are on other architectures?
I'm just wondering if e1000_netpoll should be the reccomended method
to support NAPI.

thanks,
grant
