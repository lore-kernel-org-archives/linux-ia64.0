From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Wed, 09 Mar 2005 16:35:00 +0000
Subject: RE: PCI Express
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502407F93B0F@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 08, 2005 at 05:29:13PM -0800, Jesse Barnes wrote:
...
> An MSI should behave like a processor sending an IPI to itself since
its 
> address can be targeted at the processor's interrupt block and set to 
> generate a local interrupt.  Is that right, Tom & Grant?

MSI address is programmed at 0xfeex_xxxx (based on PCI Specs) to
generate a memory write to FSB. This address can be configured to target
a platform interrupt controller (like IOAPIC for example), which in turn
generates a memory write to a FSB, or be configured to send a memory
write directly to FSB. Existing MSI support implements a direct
memory-write mechanism (generic solution without platform dependency and
limitation to MSI-X support as an example). With existing direct
memory-write mechanism, a device's MSI address is configured with
current running CPU as a target. MSI support also implements MSI SMP
affinity, which supports IRQ rebalance and allows user to select which
CPU target through /proc/irq/...

I hope it helps.

Thanks,
Long 

