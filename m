From: Andrew Morton <akpm@osdl.org>
Date: Mon, 26 Apr 2004 05:36:14 +0000
Subject: Re: [RFC IA64 Hotplug] [Patch 1/7] core_kernel_init.patch
Message-Id: <20040425223614.1c524722.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX4041LEdyt3cew00000172@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX4041LEdyt3cew00000172@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


These patches were disastrously wordwrapped by your mailer (usually an
indication that the code is using too-long lines, too).

Having nothing better to do, I fixed them all up and applied them to my
tree, thanks.

One of the patches adds a KDB initialisation hook to init/main.c.  Was this
deliberate?

