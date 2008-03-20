From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Thu, 20 Mar 2008 09:13:43 +0000
Subject: Xen common code across architecture
Message-Id: <10EA09EFD8728347A513008B6B0DA77A02EF8C3A@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12047411453864-git-send-email-yamahata@valinux.co.jp> <12047411473158-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12047411473158-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org
Cc: kvm-ia64-devel@lists.sourceforge.net, xen-ia64-devel@lists.xensource.com, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Jeremy & all:
	Current xen kernel codes are in arch/x86/xen, but xen dynamic
irqchip (events.c) are common for other architectures such as IA64. We
are in progress with enabling pv_ops for IA64 now and want to reuse same
code, do we need to move the code to some place common? suggestions?
	Thanks, eddie
