From: Grant Grundler <iod00d@hp.com>
Date: Wed, 25 Aug 2004 15:52:13 +0000
Subject: Re: [RFC&PATCH 1/2] PCI Error Recovery (readX_check)
Message-Id: <20040825155213.GB19447@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <412AD123.8050605@jp.fujitsu.com> <Pine.LNX.4.58.0408232231070.17766@ppc970.osdl.org> <1093417267.2170.47.camel@gaston> <Pine.LNX.4.58.0408250015420.17766@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0408250015420.17766@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, Aug 25, 2004 at 12:20:45AM -0700, Linus Torvalds wrote:
> Because if you don't lock the bridge (or whatever the entity is that keeps 
> track of errors), the whole exercise is kind of pointless. If two drivers 
> try to do error checking at the same time, and will potentially clear the 
> errors of each other, causing the errors to get lost, the whole recovery 
> infrastructure is clearly worthless.

Do we only need to determine there was an error in the IO hierarchy
or do we also need to know which device/driver caused the error?

If the latter I agree with linus. If the former, then the error recovery
can support asyncronous errors (like the bad DMA address case) and tell
all affected (thanks willy) drivers.

grant
