From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 21 Jan 2013 22:15:58 +0000
Subject: Re: [PATCH v4 00/13] Add gdb python scripts as kernel debugging helpers
Message-Id: <20130121221558.GS30577@one.firstfloor.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1358787929.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1358787929.git.jan.kiszka@siemens.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

> 
>  o Install that kernel on the guest

If you use a static kernel you can also do 

- copy the initrd out of the guest once

qemu...  -bzImage kernel -initrd initrd

This saves the step of getting the kernel into the kernel.
Doesn't work with modules unfortunately.

-Andi
