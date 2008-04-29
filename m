From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 29 Apr 2008 15:33:34 +0000
Subject: Re: 2.6.25 new perfmon kernel patch + libpfm + pfmon available
Message-Id: <20080429083334.1a019318@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804291446l4693b317ha7ee2382d00e99e6@mail.gmail.com>
	<7c86c4470804291447w713934a7o2b8a5a690fc9a535@mail.gmail.com>
	<20080429080853.48c66b29@infradead.org>
	<7c86c4470804300611s7442fe11lba2b66f5a3a8ed88@mail.gmail.com>
In-Reply-To: <7c86c4470804300611s7442fe11lba2b66f5a3a8ed88@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stephane eranian <eranian@googlemail.com>
Cc: linux-kernel@vger.kernel.org, ia64 <linux-ia64@vger.kernel.org>

On Wed, 30 Apr 2008 15:11:11 +0200
"stephane eranian" <eranian@googlemail.com> wrote:

> Sorry,
> 
> It's http://perfmon2.sf.net
> 
> 

hummmmm, I wonder why perfmon wants to reimplement half of the PCI layer...

+extern spinlock_t pci_config_lock;
+
+#define PCI_CONF1_ADDRESS(bus, devfn, reg) \
+       (0x80000000 | ((reg & 0xF00) << 16) | ((bus & 0xFF) << 16) \
+       | (devfn << 8) | (reg & 0xFC))
+
+#define is_ibs_pmc(x) (x = 4 || x = 5)
+
+static int pci_read(unsigned int seg, unsigned int bus,
+                   unsigned int devfn, int reg, int len, u32 *value)
+{
+       unsigned long flags;

especially since this doesn't seem to use the proper config space abstractions :(
