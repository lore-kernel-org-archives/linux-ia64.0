From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 10 Jun 2015 22:11:56 +0000
Subject: Re: [PATCH] ia64: remove paravirt code
Message-Id: <CA+8MBb+R-et1VNrqsV6USUphwMfhiMBbLBVrrkQcma4b=wsLbA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433270522-1973-1-git-send-email-mcgrof@do-not-panic.com>
In-Reply-To: <1433270522-1973-1-git-send-email-mcgrof@do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, pbonzini@redhat.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Chris Wright <chrisw@sous-sol.org>, Jeremy Fitzhardinge <jeremy@goop.org>, akataria@vmware.com, Rusty Russell <rusty@rustcorp.com.au>, "Luis R. Rodriguez" <mcgrof@suse.com>

On Tue, Jun 2, 2015 at 11:42 AM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>
> All the ia64 pvops code is now dead code since both
> xen and kvm support have been ripped out [0] [1]. Just
> that no one had troubled to rip this stuff out. The only
> useful remaining pieces were the old pvops docs but that
> was recently also generalized and moved out from ia64 [2].
>
> This has been run time tested on an ia64 Madison system.
>
> [0] 003f7de625890 "KVM: ia64: remove" since v3.19-rc1
> [1] d52eefb47d4eb "ia64/xen: Remove Xen support for ia64" since v3.14-rc1
> [2] "virtual: Documentation: simplify and generalize paravirt_ops.txt"
>
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
> I've build and run time tested this against linux-next tag next-20150529.
> The build will fail if you've enabled the LKDTM (Linux Kernel Dump Test
> Tool Module) enabled on SLE11 ia64 builds, a fix for which I've just
> posted [3].
>
> [3] https://marc.info/?l=linux-kernel&m3327018731361&w=2


So this builds cleanly on all my test configurations, and boots on
the one machine that I tried it on - good job.

But I'm wondering how much of this was auto-generated (and
so perhaps free from typos) and how much was done by hand?

It isn't a full revert of the patch series that added paravirt ... you
simplified macros like:
 #define MOV_TO_KR(kr, reg, clob0, clob1)       \
-       mov IA64_KR(kr) = reg                   \
-       CLOBBER(clob0)                          \
-       CLOBBER(clob1)
+       mov IA64_KR(kr) = reg

but didn't remove them completely.

So what can I do to validate this 4000+ line patch?  Can I compare
disassembled ".o" files pre/post patch somehow to be sure this doesn't
have some small typo errors somewhere?

-Tony
