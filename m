From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 18 Dec 2008 10:24:36 +0000
Subject: Re: [RFC 2/2] dyn ftrace porting of IA64
Message-Id: <20081218102436.GA10513@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1229570241.28616.32.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1229570241.28616.32.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


* Steven Rostedt <srostedt@redhat.com> wrote:

> On Thu, 2008-12-18 at 11:17 +0800, Shaohua Li wrote:
> > This is the IA64 port of dyn ftrace. In IA64, there are some issues we
> > must solve.
> > 1. kernel compile has different option against module compile, so I
> > extend the Makefile.build/recordmcount.pl script to distinct the two
> > cases.
> > 2. in a module, each routine's mcount call will call a PLT stub, which
> > will call kernel mcount. We can't simply make the mcount call call into
> > kernel mcount, as kernel and mocule have different gp and the
> > instruction just supports 25bit offset. So I introduced a new PLT stub,
> > which will call into kernel ftrace_caller. When module loading, all
> > mcount call will be converted to nop. When the nop is converted to call,
> > we make the call to the new PLT stub instead of old mcount PLT stub.
> 
> Have you taken a look at how powerpc64 does it?
> 
> You can look at Ingo's tip tree under the branch tip/tracing/powerpc, or 
> my own tree under tip/ftrace/ppc.

it's at:

  http://people.redhat.com/mingo/tip.git/README

> My tree is at:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git

	Ingo
