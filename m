From: John Partridge <johnip@sgi.com>
Date: Thu, 02 Nov 2006 01:08:37 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <45494515.8050304@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061031204717.GG26964@parisc-linux.org>	<ada4ptkt8y2.fsf@cisco.com>	<4548CAE7.8010300@sgi.com> <20061101.150418.26278280.davem@davemloft.net>
In-Reply-To: <20061101.150418.26278280.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: rdreier@cisco.com, matthew@wil.cx, jmodem@AbominableFirebug.com, mst@mellanox.co.il, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz

David Miller wrote:
> From: John Partridge <johnip@sgi.com>
> Date: Wed, 01 Nov 2006 10:27:19 -0600
> 
> 
>>Sorry, but I find this change a bit puzzling. The problem is
>>particular to the PPB on the HCA and not Altix. I can't see anywhere
>>that a PCI Config Write is required to block until completion, it is
>>the driver and the HCA ,not the Altix hardware that requires the
>>Config Write to have completed before we leave mthca_reset()
>>Changing pci_write_config_xxx() will change the behavior for ALL
>>drivers and the possibility of breaking something else. The fix was
>>very low risk in mthca_reset(), changing the PCI code to fix this is
>>much more onerous.
> 
> 
> The issue is that something as simple as:
> 
> 	val = pci_read_config(REG);
> 	val |= bit;
> 	pci_write_config(REG, val);
> 	newval = pci_read_config(REG);
> 	BUG_ON(!(newval & bit));
> 
> is not guarenteed by PCI (aparently).
> 
> I see no valid reason why every PCI device driver should
> be troubled with this lunacy and the ordering should thus
> be ensured by the PCI layer.
> 
> It just so happens to take care of the original driver
> issue too :-)

Yeah, Matthew has convinced me of that now.

Thanks


-- 
John Partridge

Silicon Graphics Inc
Tel:	651-683-3428
Vnet:	233-3428
E-Mail:	johnip@sgi.com
