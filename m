From: Andi Kleen <ak@suse.de>
Date: Fri, 31 Mar 2006 13:28:17 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <p73vetu921a.fsf@verdi.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> writes:
> MODE_BARRIER
> 	An atomic operation that is guaranteed to occur between
> 	previous and later memory operations.


I think it's a bad idea to create such an complicated interface.
The chances that an average kernel coder will get these right are
quite small. And it will be 100% untested outside IA64 I guess
and thus likely be always slightly buggy as kernel code continues
to change.

-Andi
