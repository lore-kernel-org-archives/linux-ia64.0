From: Andrew Morton <akpm@osdl.org>
Date: Wed, 06 Apr 2005 23:40:25 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <20050406164025.5fb29977.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rajesh Shah <rajesh.shah@intel.com> wrote:
>
> On Wed, Apr 06, 2005 at 03:48:38PM -0700, Andrew Morton wrote:
> > Andrew Morton <akpm@osdl.org> wrote:
> > >
> > > Do we know what the problem was with
> > > add-a-clear_pages-function-to-clear-pages-of-higher.patch?  Was it a build
> > > error or a compile error?
> > 
> > err, s/build/runtime/
> 
> That was a compile error too:
> 
> arch/ia64/kernel/ia64_ksyms.c:41: error: `clear_page' undeclared here (not in a function)
> arch/ia64/kernel/ia64_ksyms.c:41: error: initializer element is not constant
> arch/ia64/kernel/ia64_ksyms.c:41: error: (near initialization for `__ksymtab_clear_page.value')
> arch/ia64/kernel/ia64_ksyms.c:41: error: __ksymtab_clear_page causes a section type conflict
> make[1]: *** [arch/ia64/kernel/ia64_ksyms.o] Error 1

Oh, OK.  The patch I have doesn't add a clear_pages function to ia64 at
all, so I'm not sure what's supposed to be going on.

It almost looks like we lost great chunks of that patch somewhere along the
line.

Oh well, I'll drop it for now.  Christoph, could you please double-check
everything (including the x86 mmx thing) and resend?

