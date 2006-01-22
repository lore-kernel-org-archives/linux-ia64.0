From: Tony Luck <tony.luck@intel.com>
Date: Sun, 22 Jan 2006 20:59:02 +0000
Subject: Re: [PATCH] disable per cpu intr in /proc/stat
Message-Id: <12c511ca0601221259i25f26410l5c94871b7495283f@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060122202204.GA26295@suse.de>
	 <20060122123150.3a289ac3.akpm@osdl.org>
In-Reply-To: <20060122123150.3a289ac3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Olaf Hering <olh@suse.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On 1/22/06, Andrew Morton <akpm@osdl.org> wrote:
> Olaf Hering <olh@suse.de> wrote:
> > Don't compute and display the per-irq sums on ia64 either, too much
> > overhead for mostly useless figures.
>
> We'd need a big ack from the ia64 team for this, please.

This was found early in December.  I proposed:
http://marc.theaimsgroup.com/?l=linux-kernel&m3398553428807&w=2
dropping it for all architectures, but got no response.

The problem is the horribly cache unfriendly scan of all percpu
structures ... not too much of a problem for low cpu count, but
really bad when the count gets high (just configured high is
enough to cause the problem in a CONFIG_HOTPLUG_CPU
kernel ... even if the cpu isn't present we still scan).

An alternative if someone really is using these values would be
to compute the sums earlier in the function ... but that would
require a memory allocation to save the per-irq sums.

Unless someone comes up soon with the name of an existing
application that depends on these per-irq sums, consider this

Acked-by: Tony Luck <tony.luck@intel.com>

-Tony
