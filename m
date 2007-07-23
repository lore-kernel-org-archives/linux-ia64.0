From: Len Brown <lenb@kernel.org>
Date: Mon, 23 Jul 2007 17:47:57 +0000
Subject: Re: Linus' tree broken?
Message-Id: <200707231347.57366.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 23 July 2007 12:05, Luck, Tony wrote:
> > Have anyone else had seen issues with the Linus git tree failing to
> > boot? I'm trying a pull as of this morning and it seems to hang when
> > it's brining up the ethernet devices.
> >
> > It's not locking up, just the boot scripts never continues - happens
> > both on SLES10 and FC7 roots :(
> >
> > Just wanted to check before spending real time on it.
> 
> Pulled Linus' tree (the -rc1 commit is at the head) and it built
> and booted on my tiger.  Only new strange stuff in the dmesg is a
> lot of
> 
> ACPI Exception (processor_throttling-0084): AE_NOT_FOUND, Evaluating _PTC [20070126]
> ACPI Exception (processor_throttling-0147): AE_NOT_FOUND, Evaluating _TSS [20070126]
> 
> messages (this pair of message repeats 16 times)

ignore those, they're harmless and going away shortly.

-Len
