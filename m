From: Jes Sorensen <jes@sgi.com>
Date: Tue, 12 Sep 2006 09:12:26 +0000
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
Message-Id: <450679FA.7040704@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andi Kleen wrote:
>> So I totally agree, GFP_DMA allocations really ought to fail in this
>> situation and we should fixup the users instead.
> 
> It's just impossible to fix them without having a bounce buffer.
> The only way would be to not use the hardware. I guess 
> we can find out how many people still use floppies and other
> such hardware by having it for some time in -mm*.

Actually I was somehow unclear in my mail. You are right about the 24bit
zone, but there is also the issue of the 32bit zone to deal with, which
is what I had in mind. This is still common, even if things like ISA and
floppies are history.

> But I reserve the right that if this thing becomes a FAQ - e.g. 
> various people set the option wrong and break their systems
> to rip it out again. I'm not interested at all in patches that increase
> the bogus bug report rate. 

Nod, I am worried if we get to a state with random bug reports or 32bit
cards not working because of this. You may be able to explain it to
users one at a time, but I really don't feel like spending my time doing
that :)

Cheers,
Jes

