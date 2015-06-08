From: "Luis R. Rodriguez" <mcgrof@suse.com>
Date: Mon, 08 Jun 2015 23:34:08 +0000
Subject: Re: [PATCH] ia64: remove paravirt code
Message-Id: <CAB=NE6XfZ7Y58nvLwyF0izFePuwVrNNZ6NGhE31RTsUrEQM8PQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433270522-1973-1-git-send-email-mcgrof@do-not-panic.com>
In-Reply-To: <1433270522-1973-1-git-send-email-mcgrof@do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, pbonzini@redhat.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Chris Wright <chrisw@sous-sol.org>, Jeremy Fitzhardinge <jeremy@goop.org>, Alok Kataria <akataria@vmware.com>, Rusty Russell <rusty@rustcorp.com.au>, "Luis R. Rodriguez" <mcgrof@suse.com>

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

Hey folks, any feedback?

 Luis
