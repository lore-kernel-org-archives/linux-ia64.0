From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 20 Mar 2008 14:23:04 +0000
Subject: Re: Xen common code across architecture
Message-Id: <47E27348.5090705@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <12047411453864-git-send-email-yamahata@valinux.co.jp>	<12047411473158-git-send-email-yamahata@valinux.co.jp> <10EA09EFD8728347A513008B6B0DA77A02EF8C3A@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A02EF8C3A@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dong, Eddie" <eddie.dong@intel.com>
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, xen-ia64-devel@lists.xensource.com

Dong, Eddie wrote:
> 	Current xen kernel codes are in arch/x86/xen, but xen dynamic
> irqchip (events.c) are common for other architectures such as IA64. We
> are in progress with enabling pv_ops for IA64 now and want to reuse same
> code, do we need to move the code to some place common? suggestions?

I'm fine with moving common stuff like that to drivers/xen/.

    J
