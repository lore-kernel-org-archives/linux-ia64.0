From: Keith Owens <kaos@sgi.com>
Date: Sat, 28 Feb 2004 14:47:54 +0000
Subject: Re: Oops in pdflush
Message-Id: <17292.1077979674@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 28 Feb 2004 04:00:34 -0800, 
Andrew Morton <akpm@osdl.org> wrote:
>Having just looked at the code, I don't understand the problem.
>
>If kernel thread A starts kernel thread B and kernel thread B starts
>kernel thread C and so on, how does that cause stack windup?

Backtrace from a pdflush task on standard 2.6.3 ia64.

schedule+0xf30
__pdflush+0x230
pdflush+0x20
kernel_thread+0x100
pdflush_init+0x30
do_initcalls+0xc0
init+0xe0
kernel_thread+0x100
rest_init+0x30
start_kernel+0x460
_start+0x280

Each use of kernel_thread results in a cloned stack which inherits the
stack usage from the previous thread.  Some architectures have a
kernel_thread helper which resets the stack, others do not.  Without a
helper, each call whittles away at the stack.

