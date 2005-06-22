From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 22 Jun 2005 04:53:35 +0000
Subject: RE: Variation in measure_migration_cost() with scheduler-cache-hot-autodetect.patch in -mm
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03BF8F41@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506220319.j5M3JRg30716@unix-os.sc.intel.com>
In-Reply-To: <200506220319.j5M3JRg30716@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nitpick: 

> 		printk("could not vmalloc %d bytes for cache!\n", 2*max_size);

You should change this printk() message to not say "vmalloc".

-Tony
