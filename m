From: Keith Owens <kaos@sgi.com>
Date: Wed, 15 Mar 2006 05:58:28 +0000
Subject: Re: [patch 1/6] add __init declaration to mca functions
Message-Id: <31080.1142402308@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603121652.k2CGqIg10015@unix-os.sc.intel.com>
In-Reply-To: <200603121652.k2CGqIg10015@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Chen, Kenneth W" (on Sun, 12 Mar 2006 08:52:20 -0800) wrote:
>Mark init related variable and functions with appropriate
>__init* declaration to mca functions.
>
>
>Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
>
>--- ./arch/ia64/kernel/mca.c.orig	2006-03-12 01:23:18.000000000 -0800
>+++ ./arch/ia64/kernel/mca.c	2006-03-12 09:01:44.713161302 -0800
>@@ -133,7 +133,7 @@ static int cpe_poll_enabled = 1;
> 
> extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
> 
>-static int mca_init;
>+static int mca_init __initdata;

Coding style niggle.  Attributes like __initdata usually come before
the variable name, for readibility.

