From: Joel Fernandes <joel@joelfernandes.org>
Date: Sat, 13 Oct 2018 02:10:57 +0000
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
Message-Id: <20181013021057.GA213522@joelaf.mtv.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181012013756.11285-2-joel@joelfernandes.org>
 <20181012113056.gxhcbrqyu7k7xnyv@kshutemo-mobl1>
 <20181012125046.GA170912@joelaf.mtv.corp.google.com>
 <20181012.111836.1569129998592378186.davem@davemloft.net>
 <20181013013540.GA207108@joelaf.mtv.corp.google.com>
 <CAKOZueuNvWvn18vffJWpbpg7h-uScT8gXrrudTB2pnT4M2HJ_w@mail.gmail.com>
 <20181013014429.GB207108@joelaf.mtv.corp.google.com>
 <CAKOZues25aaKz3_AiyfJ=r2QBd5MghgY3ky_ptg4Z8=ST4DCgw@mail.gmail.com>
In-Reply-To: <CAKOZues25aaKz3_AiyfJ=r2QBd5MghgY3ky_ptg4Z8=ST4DCgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Colascione <dancol@google.com>
Cc: David Miller <davem@davemloft.net>, kirill@shutemov.name, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@android.com, Minchan Kim <minchan@kernel.org>, Ramon Pantin <pantin@google.com>, hughd@google.com, Lokesh Gidra <lokeshgidra@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, aryabinin@virtuozzo.com, luto@kernel.org, bp@alien8.de, catalin.marinas@arm.com, chris@zankel.net, dave.hansen@linux.intel.com, elfring@users.sourceforge.net, fenghua.yu@intel.com, geert@linux-m68k.org, gxt@pku.edu.cn, deller@gmx.de, mingo@redhat.com, jejb@parisc-linux.org, jdike@addtoit.com, jonas@southpole.se, Julia.Lawall@lip6.fr, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, lftan@altera.com, linux-alpha@vger.kernel.orglinux

On Fri, Oct 12, 2018 at 06:54:33PM -0700, Daniel Colascione wrote:
> I wonder whether it makes sense to expose to userspace somehow whether
> mremap is "fast" for a particular architecture. If a feature relies on
> fast mremap, it might be better for some userland component to disable
> that feature entirely rather than blindly use mremap and end up
> performing very poorly. If we're disabling fast mremap when THP is
> enabled, the userland component can't just rely on an architecture
> switch and some kind of runtime feature detection becomes even more
> important.

I hate to point out that its forbidden to top post on LKML :-)
https://kernelnewbies.org/mailinglistguidelines
So don't that Mr. Dan! :D

But anyway, I think this runtime detection thing is not needed. THP is
actually expected to be as fast as this anyway, so if that's available then
we should already be as fast. This is for non-THP where THP cannot be enabled
and there is still room for some improvement. Most/all architectures will be
just fine with this. This flag is more of a safety-net type of thing where in
the future if there is this one or two weird architectures that don't play
well, then they can turn it off at the architecture level by not selecting
the flag. See my latest patches for the per-architecture compile-time
controls. Ideally we'd like to blanket turn it on on all, but this is just
playing it extra safe as Kirill and me were discussing on other threads.

thanks!

- Joel
