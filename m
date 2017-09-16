From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 16 Sep 2017 11:25:35 +0000
Subject: Re: [PATCH 3/5] powerpc64: Add .opd based function descriptor dereference
Message-Id: <20170916112535.GA495@tigerII.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
 <20170916035347.19705-4-sergey.senozhatsky@gmail.com>
 <20170916094345.d332z3odceqiyrll@naverao1-tp.localdomain>
In-Reply-To: <20170916094345.d332z3odceqiyrll@naverao1-tp.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Jessica Yu <jeyu@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Nicholas Piggin <npiggin@gmail.com>

On (09/16/17 15:13), Naveen N. Rao wrote:
[..]
> Would it be simpler to just use kernel_text_address() and dereference 
> everything else? See commit 83e840c770f2c5 ("powerpc64/elfv1: Only 
> dereference function descriptor for non-text symbols") for a related 
> patch.

I had this idea, see

lkml.kernel.org/r/20170908172528.qc2vdtxzqh777k6o@intel.com


	-ss
