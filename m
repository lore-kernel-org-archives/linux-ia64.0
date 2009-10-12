From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 12 Oct 2009 14:24:30 +0000
Subject: [PATCH] ia64: Don't call SAL < 3.2 for extended config space
Message-Id: <20091012142430.GE7545@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091011074531.GA12357@grsecurity.net> <4AD1AE0D.1030007@kernel.org> <4AD24766.7050205@kernel.org> <20091011213245.GC18513@grsecurity.net> <20091011231039.GB7545@parisc-linux.org> <20091012135628.GA310@grsecurity.net>
In-Reply-To: <20091012135628.GA310@grsecurity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brad Spengler <spender@grsecurity.net>
Cc: Yinghai Lu <yinghai@kernel.org>, Jesse Barnes <jbarnes@virtuousgeek.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org

On Mon, Oct 12, 2009 at 09:56:28AM -0400, Brad Spengler wrote:
> > So how about we go back to adding that check ... this does require that
> > SGI's 750 machine reports its SAL revision correctly.  Could you send
> > the dmesg?
> 
> The dmesg of the working kernel:
> http://grsecurity.net/~spender/dmesg.txt

Thanks, that's reporting SAL 3.0, so it will be correctly caught by
this patch:

---

From: Matthew Wilcox <willy@linux.intel.com>
Subject: Require SAL 3.2 in order to do extended config space ops

We had assumed that SAL firmware would return an error if it didn't
understand extended config space.  Unfortunately, the SAL on the SGI 750
doesn't do that, it panics the machine.  So, condition the extended PCI
config space accesses on SAL revision 3.2.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 7de76dd..61363cc 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -56,10 +56,13 @@ int raw_pci_read(unsigned int seg, unsigned int bus, unsigned int devfn,
 	if ((seg | reg) <= 255) {
 		addr = PCI_SAL_ADDRESS(seg, bus, devfn, reg);
 		mode = 0;
-	} else {
+	} else if (sal_revision >= SAL_VERSION_CODE(3,2))
 		addr = PCI_SAL_EXT_ADDRESS(seg, bus, devfn, reg);
 		mode = 1;
+	} else {
+		return -EINVAL;
 	}
+
 	result = ia64_sal_pci_config_read(addr, mode, len, &data);
 	if (result != 0)
 		return -EINVAL;
@@ -80,9 +83,11 @@ int raw_pci_write(unsigned int seg, unsigned int bus, unsigned int devfn,
 	if ((seg | reg) <= 255) {
 		addr = PCI_SAL_ADDRESS(seg, bus, devfn, reg);
 		mode = 0;
-	} else {
+	} else if (sal_revision >= SAL_VERSION_CODE(3,2))
 		addr = PCI_SAL_EXT_ADDRESS(seg, bus, devfn, reg);
 		mode = 1;
+	} else {
+		return -EINVAL;
 	}
 	result = ia64_sal_pci_config_write(addr, mode, len, value);
 	if (result != 0)

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
