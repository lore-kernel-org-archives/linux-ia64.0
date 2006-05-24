From: Jeff Hanson <jhanson@sgi.com>
Date: Wed, 24 May 2006 21:37:58 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <4474D236.4050707@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Cc: list pruned to stop annoying the innocent bystanders ...
> 
>>> I've been thinking of dropping CONFIG_IA32_SUPPORT completely from ia64.
>>> I've heard no complaints that new syscalls are not being added to the
>>> ia32 compat side ... which is an indication that people are not
>>> actively using this.
>> Or maybe the people using ia32 compatibility are just running big
>> apps like Firefox or Open Office that are non-trivial to build for
>> ia64, but may not care as much about shiny new syscalls.
> 
> Firefox has been ported ... it came as a native ia64 binary
> rpm on the last OSD install disk that I put on my workstation.
> Dunno about Open office though.

Native port of Open Office is supposed to be very hard because the
UNO bridge code is specific to each architecture.
-- 
-----------------------------------------------------------------------
Jeff Hanson - jhanson@sgi.com - Field Technical Analyst

You can choose a ready guide in some celestial voice.
If you choose not to decide, you still have made a choice.
You can choose from phantom fears and kindness that can kill;
I will choose a path that's clear
I will choose freewill. - Lee/Lifeson/Peart
