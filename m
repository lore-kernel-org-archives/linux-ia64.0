From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 17:45:18 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603310943480.6628@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
 <p73vetu921a.fsf@verdi.suse.de>
In-Reply-To: <p73vetu921a.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 31 Mar 2006, Andi Kleen wrote:

> Christoph Lameter <clameter@sgi.com> writes:
> > MODE_BARRIER
> > 	An atomic operation that is guaranteed to occur between
> > 	previous and later memory operations.
> I think it's a bad idea to create such an complicated interface.
> The chances that an average kernel coder will get these right are
> quite small. And it will be 100% untested outside IA64 I guess
> and thus likely be always slightly buggy as kernel code continues
> to change.

Powerpc can do similar things AFAIK. Not sure what other arches have 
finer grained control over barriers but it could cover a lot of special 
cases for other processors as well.

