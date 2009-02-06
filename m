From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Feb 2009 18:42:07 +0000
Subject: RE: [PATCH] ia64: prevent irq migration race in __cpu_disable path
Message-Id: <57C9024A16AD2D4C97DC78E552063EA36121A469@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206162213.GD8208@ldl.fc.hp.com>
In-Reply-To: <20090206162213.GD8208@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "stable@kernel.org" <stable@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>

> This is wrong because fixup_irqs calls migrate_irqs, and in
> migrate_irqs, we use the cpu_online_map to:
>
>       1. look for interrupts on current CPU
>       2. if we find one, move it to the first available CPU in
>       the cpu_online_map
>
> This means we can potentially migrate an interrupt off ourself
> back to... ourself. Uh oh.

Should we make migrate_irqs smarter then ... does any caller really
expect that it would "migrate" the irq to the same cpu?

-Tony
