From: Helge Deller <deller@gmx.de>
Date: Mon, 13 Nov 2017 17:17:54 +0000
Subject: Re: [PATCHv4 0/6] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <f7ba9e1c-10d8-3519-faad-7520c450c3e9@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On 10.11.2017 00:48, Sergey Senozhatsky wrote:
> 	All Ack-s/Tested-by-s were dropped, since the patch set has been
> reworked. I'm kindly asking arch-s maintainers and developers to test it
> once again. Sorry for any inconveniences and thanks for your help in
> advance.

I tested it successfully on parisc64.
You can add back the
Tested-by: Helge Deller <deller@gmx.de> #parisc64

Thanks!
Helge
