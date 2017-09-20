From: Helge Deller <deller@gmx.de>
Date: Wed, 20 Sep 2017 20:14:49 +0000
Subject: Re: [RFC][PATCH v2 0/7] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <b0665fe7-fc57-7795-3cee-f33cd806b850@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>
Cc: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On 20.09.2017 18:29, Sergey Senozhatsky wrote:
>          This patch set attempts to move ia64/ppc64/parisc64 C function
> pointer ABI details out of printk() to arch code. Function dereference
> code now checks if a pointer belongs to a .opd ELF section and dereferences
> that pointer only if it does. The kernel and modules have their own .opd
> sections that's why I use two different ARCH functions: for kernel and
> for module pointer dereference.
> ...> *** A BIG NOTE ***
>          I don't own ia64/ppc64/parisc64 hardware, so the patches are not
>          tested. Sorry about that!


I just now tested your patch series successfully on parisc64.

You may add to the whole series:
Tested-by: Helge Deller <deller@gmx.de> # parisc64

  
> Another note:
>          I need to check what is BPF symbol lookup and do we need to
>          do any dereference there.

Not relevant for parisc, since we don't support it yet.

Helge
