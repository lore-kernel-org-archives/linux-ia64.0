From: Andrew Morton <akpm@osdl.org>
Date: Sun, 11 Jul 2004 10:02:25 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <20040711030225.11fb61e7.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
	<Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
In-Reply-To: <Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>
Cc: davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, torvalds@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Ingo Molnar <mingo@redhat.com> wrote:
>
> +#ifdef __i386_

You'll be wanting __i386__ there.

Apropos of nothing much, CONFIG_X86 would be preferreed here, but x86_64
defines that too.

Is there a CONFIG symbol which is unique to i386?  If not, perhaps we
should define one (CONFIG_I386?)
