From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 18 Feb 2004 19:13:59 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <20040218191359.A11957@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 18, 2004 at 10:59:03AM -0800, David Mosberger wrote:
> This comment concerns me.  I certainly have always tried to judge
> patches based on their technical merits for Linux.  Is there anything
> in particular that I did (or didn't) do that you found objectionable?
> If so, please let me know.

Nah, this wasn't meant as an attac against you, it's just that HP seems
to do most of the work and thus everything in arch/ia64/ is a little
HP centric.  I guess it'll change by the time now that SGI woke up
a little.

> Hmmh, I'm no NUMA-expert and it isn't clear to me whether the patch is
> working around a firmware-bug or a limitation in the Linux NUMA code.
> I don't see off-hand why it should be illegal to have a memory config
> with only one node with memory.  The whole PXM_MAGIC business looks
> strange to me though.  Can someone explain?

There's two issues. First we should probably handle CPU-less nodes, but
that's not what this patch does.

The second issue is that the firmware reports plain wrong data to work
around the lack of NUMA support in a certain legacy OS from Redmond, and
I don't think we should so this non-standard workaround in Linux for that.

Robert's idea of a switch in the firmware to report proper tables sounds
like the best way to go, maybe together with a fix to allow cpu-less nodes
to allow boxes with old firmware to boot, even with suboptimal performance.

