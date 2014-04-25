From: David Miller <davem@davemloft.net>
Date: Fri, 25 Apr 2014 16:49:03 +0000
Subject: Re: [PATCH 07/13] sparc/PCI: Use new pci_is_bridge() to simplify code
Message-Id: <20140425.124903.145066741692796378.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1398417515-8740-1-git-send-email-wangyijing@huawei.com>
	<1398417515-8740-8-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1398417515-8740-8-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wangyijing@huawei.com
Cc: bhelgaas@google.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org, tglx@linutronix.de, x86@kernel.org, benh@kernel.crashing.org

From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 25 Apr 2014 17:18:29 +0800

> Now we can use new pci_is_bridge() helper function
> to simplify code.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Acked-by: David S. Miller <davem@davemloft.net>
