From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Nov 2017 18:11:15 +0000
Subject: Re: [PATCHv4 0/6] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20171110181114.x22y2zr5qdf4y5za@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Nov 10, 2017 at 08:48:24AM +0900, Sergey Senozhatsky wrote:
> 	All Ack-s/Tested-by-s were dropped, since the patch set has been
> reworked. I'm kindly asking arch-s maintainers and developers to test it
> once again. Sorry for any inconveniences and thanks for your help in
> advance.

You can add back the:

Tested-by: Tony Luck <tony.luck@intel.com> #ia64

Apart from my comment about dropping the Examples from the
Documentation the series looks OK to me.

-Tony
