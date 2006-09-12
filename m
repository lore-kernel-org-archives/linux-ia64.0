From: Andi Kleen <ak@suse.de>
Date: Tue, 12 Sep 2006 07:22:53 +0000
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
Message-Id: <200609120922.54307.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> So I totally agree, GFP_DMA allocations really ought to fail in this
> situation and we should fixup the users instead.

It's just impossible to fix them without having a bounce buffer.
The only way would be to not use the hardware. I guess 
we can find out how many people still use floppies and other
such hardware by having it for some time in -mm*.

But I reserve the right that if this thing becomes a FAQ - e.g. 
various people set the option wrong and break their systems
to rip it out again. I'm not interested at all in patches that increase
the bogus bug report rate. 

-Andi

