From: Andi Kleen <ak@suse.de>
Date: Fri, 31 Mar 2006 17:48:37 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <200603311948.38218.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com> <p73vetu921a.fsf@verdi.suse.de> <Pine.LNX.4.64.0603310943480.6628@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603310943480.6628@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Friday 31 March 2006 19:45, Christoph Lameter wrote:
> On Fri, 31 Mar 2006, Andi Kleen wrote:
> 
> > Christoph Lameter <clameter@sgi.com> writes:
> > > MODE_BARRIER
> > > 	An atomic operation that is guaranteed to occur between
> > > 	previous and later memory operations.
> > I think it's a bad idea to create such an complicated interface.
> > The chances that an average kernel coder will get these right are
> > quite small. And it will be 100% untested outside IA64 I guess
> > and thus likely be always slightly buggy as kernel code continues
> > to change.
> 
> Powerpc can do similar things AFAIK. Not sure what other arches have 
> finer grained control over barriers but it could cover a lot of special 
> cases for other processors as well.

Yes, but I don't think the goal of a portable atomic operations API
in Linux is it to cover everybody's special case in every possible 
combination. The goal is to have an abstraction that will lead to 
portable code. I don't think your proposal will do this.

-Andi
