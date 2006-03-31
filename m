From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 00:50:15 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310049.k2V0nVg26779@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301642330.2068@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 4:45 PM
> > I would make that MODE_RELEASE for clear_bit, simply to match the
> > observation that clear_bit is usually used in unlock path and have
> > potential less surprises.
> 
> clear_bit per se is defined as an atomic operation with no implications 
> for release or acquire. If it is used for release then either add the 
> appropriate barrier or use MODE_RELEASE explicitly.
> 
> It precise the uncleanness in ia64 that such semantics are attached to 
> these bit operations which may lead people to depend on those. We need to 
> either make these explicit or not depend on them.

I know, I'm saying since it doesn't make any difference from API point of
view whether it is acq, rel, or no ordering, then just make them rel as a
"preferred" Operation on ia64.

- Ken
