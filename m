From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 29 Sep 2008 20:55:04 +0000
Subject: RE: kdump broken on Altix 350
Message-Id: <57C9024A16AD2D4C97DC78E552063EA34DB4172D@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080829180302.6e67c26e@halley.suse.de>
	<20080829180531.0524a1e4@halley.suse.de>
	<57C9024A16AD2D4C97DC78E552063EA30A0067D6@orsmsx505.amr.corp.intel.com>
	<20080910134805.488b43f9@kepler.site> <48C82C4F.1050002@sgi.com>
	<48DD8595.6030504@sgi.com>
In-Reply-To: <48DD8595.6030504@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jay Lan <jlan@sgi.com>
Cc: "kexec@lists.infradead.org" <kexec@lists.infradead.org>, Bernhard Walle <bwalle@suse.de>, Simon Horman <horms@verge.net.au>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Maybe I'm starting to see what happened ... and it could well
be my fault.

I wanted to allocate the per-cpu memory for cpu0 statically
in the vmlinux ... so it would be available in head.S to set
up everything before we move to any C code that might try to
access per cpu variables.  To make life easy for myself I just
made this allocation in vmlinus.lds.S immediately before the
initialized block where all the percpu variables live (which
means no extra labels ... and I could initialize this data
with a simple copy of PERCPU_PAGESIZE bytes from (the poorly
named) __phys_per_cpu_start to the unamed block before it
that will be the cpu0 copy.

But my extra allocation is in the "percpu" block in vmlinux.lds.S,
so it ends up in that PT_LOAD section.  Which ultimately confuses
the kexec code.

Probably the cpu0 percpu space should be placed in the data section.

-Tony
