From: David Howells <dhowells@redhat.com>
Date: Wed, 19 Jun 2013 10:05:52 +0000
Subject: Re: [PATCH v2] mn10300: Fix include dependency in irqflags.h et al.
Message-Id: <899.1371636352@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1371483967-22527-1-git-send-email-ddaney.cavm@gmail.com> <1371413189-2568-3-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1371483967-22527-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ddaney.cavm@gmail.com
Cc: dhowells@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com, david.s.daney@gmail.com, David Daney <david.daney@cavium.com>

ddaney.cavm@gmail.com wrote:

> From: David Daney <david.daney@cavium.com>
> 
> We need to pick up the definition of raw_smp_processor_id() from
> asm/smp.h.  For the !SMP case, we need to supply a definition of
> raw_smp_processor_id().
> 
> Because of the include dependencies we cannot use smp_call_func_t in
> asm/smp.h, but we do need linux/thread_info.h
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: David Howells <dhowells@redhat.com>
