From: Jonathan Corbet <corbet@lwn.net>
Date: Thu, 03 Dec 2020 22:36:42 +0000
Subject: Re: [PATCH 0/6] Add documentation for Documentation/features at the built docs
Message-Id: <20201203153642.594afd85@lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1606748711.git.mchehab+huawei@kernel.org>
In-Reply-To: <cover.1606748711.git.mchehab+huawei@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mauro Carvalho Chehab <mchehab+huawei@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>, linux-kernel@vger.kernel.org, "Daniel W. S. Almeida" <dwlsalmeida@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Jonathan =?UTF-8?B?TmV1c2Now6RmZXI=?= <j.neuschaefer@gmx.net>, Albert Ou <aou@eecs.berkeley.edu>, Andrew Cooper <andrew.cooper3@citrix.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Heiko Carstens <hca@linux.ibm.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Jonas Bonn <jonas@southpole.se>, Kees Cook <keescook@chromium.org>, Masami Hiramatsu <mhiramat@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Palmer Dabbelt <palmer@dabbelt.com>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Rich Felker <dalias@libc.org>, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, x86@kernel.org

On Mon, 30 Nov 2020 16:36:29 +0100
Mauro Carvalho Chehab <mchehab+huawei@kernel.org> wrote:

> This series got already submitted last year:
> 
>    https://lore.kernel.org/lkml/cover.1561222784.git.mchehab+samsung@kernel.org/
> 
> Yet, on that time, there were too many other patches related to ReST
> conversion floating around. So, at the end, I guess this one got missed.
> 
> So, I did a rebase on the top of upstream, and added a few new changes.

OK, I've gone ahead and applied these; it gains me a new trivial conflict
with x86, but so be it...

That said, I think that the RST table formatting could be *way* improved.
The current tables are all white space and hard to make sense of.  What if
we condensed the information?  Just looking at the first entry in
Documentation/admin-guide/features.html, perhaps it could look like:

    FEATURE	KCONFIG/DESCRIPTION		STATUS

    cBPF-JIT	HAVE_CBPF_JIT			TODO: alpha, arc, arm...
    						ok: mips, powerpc, ...
		arch supports cBPF JIT
		optimizations

The result would be far more compact and easy to read, IMO.  I may get
around to giving this a try if (hint :) nobody else gets there first.

Thanks,

jon
