From: Tony Luck <tony.luck@intel.com>
Date: Tue, 08 Jan 2013 23:43:32 +0000
Subject: Re: [RESEND PATCH] sysctl: Enable IA64 "ignore-unaligned-usertrap" to be used cross-arch
Message-Id: <CA+8MBbKk0Gd98KBxPY9QNw7wHGAEx8K6+iKzxDAcO-s7Py9_HA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50D2B75A.3000208@synopsys.com>
	<1357195653-998-1-git-send-email-vgupta@synopsys.com>
	<1357195653-998-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1357195653-998-2-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, "Eric W. Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>

On Wed, Jan 2, 2013 at 10:47 PM, Vineet Gupta
<Vineet.Gupta1@synopsys.com> wrote:

> verbosw warnings on unaligned access emaultion.
"verbose", "emulation"

> While the exact menchaincs (ignore/shout) are still arch specific, we
"mechanics"

> +config SYSCTL_ARCH_UNALIGN_NO_WARN
> +       bool
> +       help
> +         Enable support for /proc/sys/kernel/ignore-unaligned-usertrap
> +         Allows arch to define/use @no_unaligned_warning to possbly warn about
"possibly"
> +         unaligned access emulation going on under the hood.
> +         see arch/ia64/kernel/unaligned.c for reference

It doesn't seem right to point users at an ia64 specific file now
that you are making this available to all arches.

-Tony
