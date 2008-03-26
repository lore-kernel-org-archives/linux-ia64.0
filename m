From: Dean Nelson <dcn@sgi.com>
Date: Wed, 26 Mar 2008 21:58:07 +0000
Subject: [Patch 0/5] prepare XPC and XPNET to support SGI UV -v3
Message-Id: <20080326215807.GF31340@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080325192524.343385569@attica.americas.sgi.com>
In-Reply-To: <20080325192524.343385569@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This set of five patches moves XPC and XPNET to drivers/misc/xp in preparation
for enabling X86_64 support.

I discovered that the previous versions of this patch were missing the
replacement of kernel_thread() by kthread_run() and the elimination of
daemonize().

