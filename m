From: Jay Lan <jlan@sgi.com>
Date: Mon, 07 Feb 2005 14:11:48 +0000
Subject: Re: move-accounting-function-calls-out-of-critical-vm-code-paths.patch
Message-Id: <42077724.1060606@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050110184617.3ca8d414.akpm@osdl.org>	<Pine.LNX.4.58.0502031319440.25268@schroedinger.engr.sgi.com>	<20050203140904.7c67a144.akpm@osdl.org>	<Pine.LNX.4.58.0502031436460.26183@schroedinger.engr.sgi.com> <20050203150551.4d88f210.akpm@osdl.org>
In-Reply-To: <20050203150551.4d88f210.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton wrote:
> Christoph Lameter <clameter@sgi.com> wrote:
> 
>>I hope that Roland's changes for higher resolution of cputime would
>>make that possible. But this is Jay's thing not mine. I just want to make
>>sure that the CSA patches does not get in the way of our attempts to
>>improve the performance of the page fault handler. In the discussions on
>>linux-mm there was also some concern about adding these calls.
> 
> 
> Well your patch certainly cleans things up in there and would be a good
> thing to have as long as we can be sure that it doesn't break the
> accounting in some subtle way.
> 
> Which implies that we need to see some additional accounting code, so we
> can verify that the base accumulation infrastructure is doing the expected
> thing.  As well as an ack from the interested parties.  Does anyone know
> what's happening with all the new accounting initiatives?  I'm seeing no
> activity at all.

Sorry guys! I have been away for three weeks on short term disability.:(

I have tested Christoph's patch before the leave. It did work for CSA
and showed performance improvement on certain configuration.

CSA is currently implemented as a loadable module. I think ELSA is the
same, right? The use of the enhanced accounting data collection
code is not in the kernel tree. That was why Andrew did not see usage of 
the accounting patches. Should i propose to include the CSA module in
the kernel then, Andrew? :)

Cheers,
  - jay


