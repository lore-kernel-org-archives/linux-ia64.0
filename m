From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Feb 2004 19:04:30 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <20040218190430.GM13235@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 18, 2004 at 10:59:03AM -0800, David Mosberger wrote:
>   Christoph> but honestly can't you fix the firmware to return sane
>   Christoph> information instead?  i.e. move the above fix to firmware
>   Christoph> instead of letting linux fixup the reported data.
> 
> Hmmh, I'm no NUMA-expert and it isn't clear to me whether the patch is
> working around a firmware-bug or a limitation in the Linux NUMA code.
> I don't see off-hand why it should be illegal to have a memory config
> with only one node with memory.  The whole PXM_MAGIC business looks
> strange to me though.  Can someone explain?

Well, it would be nice if memory layout was reported fully, with the
correct CPU/node and memory affinity information.  That would allow us
to either interleave in software (maybe a new flag that changes the way
discontig.c builds the memory maps) or just treat the machine as a
normal NUMA box.  But maybe this isn't possible with the HP cell boxes?
Robert, maybe you can describe the memory layout of these machines a
little more (sorry if I missed some discussion, I'm having mail trouble
right now and was unsubscribed from linux-ia64).

Thanks,
Jesse
