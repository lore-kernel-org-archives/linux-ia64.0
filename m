From: "Feldman, Scott" <scott.feldman@intel.com>
Date: Fri, 27 Feb 2004 07:11:36 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDEBC@orsmsx402.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Is this related to NAPI?
> 
> I'll assume "the gigabit" card is e1000:
> static void e1000_netpoll (struct net_device *dev) {
> 	struct e1000_adapter *adapter = dev->priv;
> 	disable_irq(adapter->pdev->irq);
> 	e1000_intr (adapter->pdev->irq, dev, NULL);
> 	enable_irq(adapter->pdev->irq);
> }

e1000_netpoll() is for netdump (netconsole) support, not NAPI.

NAPI uses dev->poll = e1000_clean.

Unfortunate similar naming for unrelated things. :-(

-scott
