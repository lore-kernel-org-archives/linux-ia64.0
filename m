From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 09 Mar 2006 18:27:43 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <Pine.LNX.4.64.0603091016480.16875@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 9 Mar 2006, Zoltan Menyhart wrote:

> In short: unless we use "srlz.d", how to make sure:
> - the visibility of the "itc" instruction to generated purges is
>  guaranteed first
> - issuing "ld" goes after ?

The manual states that serialization is only necessary before a data 
access uses the mapping. We do not use the mapping in the function we are 
discussing and I would think that the rfi is certainly serialization 
enough.

The manual also has a rather complex section on ptc purges.

I think we need to refer to how our purges work under ia64.

What we do in essence from the remote processor is:

1. We invalidate a pte (overwite the entry with zero)

2. We purge the caches (and then broadcast the purge?).

So if the fault handlers run then they will discover that either the pte 
has been zapped or the cmpxchg will fail. In either case we just do 
nothing and redo the fault.

I guess this scheme could fail if the remote processor would 
zap the pte and do the broadcast between the local processors cmpxchg and 
the itc. Thats only two bundles. 

Maybe we need some experts to explain the situation. Ken? David?

