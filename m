From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Wed, 20 Sep 2017 06:10:26 +0000
Subject: Re: [PATCH 3/5] powerpc64: Add .opd based function descriptor dereference
Message-Id: <20170920061026.GB6298@jagdpanzerIV.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
 <20170916035347.19705-4-sergey.senozhatsky@gmail.com>
 <20170916094345.d332z3odceqiyrll@naverao1-tp.localdomain>
 <87shfjkmxe.fsf@concordia.ellerman.id.au>
 <20170919103154.GC401@jagdpanzerIV.localdomain>
 <878tha9lxm.fsf@concordia.ellerman.id.au>
In-Reply-To: <878tha9lxm.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Jessica Yu <jeyu@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Nicholas Piggin <npiggin@gmail.com>

On (09/20/17 11:51), Michael Ellerman wrote:
[..]
> > unlike ppc_function_entry(), printk() can get called on any symbol,
> > not just function pointers.
> >
> > for example,
> >
> > cat /proc/kallsyms | grep shrinker_rwsem
> > ffffffff81a4b1e0 d shrinker_rwsem
> 
> Yep, good point. So your patch is probably good then. Maybe someone
> other than me can find time to test it ;)

Hi,

I'll re-spin the series today/tomorrow.

	-ss
