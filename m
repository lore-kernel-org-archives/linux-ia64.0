From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 02 Sep 2004 20:10:57 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <20040902131057.0341e337.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
	<20040815165827.0c0c8844.davem@redhat.com>
	<Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
	<20040815185644.24ecb247.davem@redhat.com>
	<Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
	<20040816143903.GY11200@holomorphy.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B679F@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67A9@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67B4@mtv-atc-605e--n.corp.sgi.com>
	<Pine.LNX.4.58.0408271616001.14712@schroedinger.engr.sgi.com>
	<1094012689.6538.330.camel@gaston>
	<Pine.LNX.4.58.0409010938200.9907@schroedinger.engr.sgi.com>
	<1094080164.4025.17.camel@gaston>
	<Pine.LNX.4.58.0409012140440.23186@schroedinger.engr.sgi.com>
	<20040901215741.3538bbf4.davem@davemloft.net>
	<Pine.LNX.4.58.0409020920570.26893@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0409020920570.26893@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: benh@kernel.crashing.org, akpm@osdl.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Thu, 2 Sep 2004 09:24:47 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Why was it done that way? Would it not be better to add the new
> functionality by giving the function another name?
> 
> Like f.e. set_pte_mm()
> 
> then one could add the following in asm-generic/pgtable.h
> 
> #ifndef __HAVE_ARCH_SET_PTE_MM
> #define set_pte_mm(mm, address, ptep, pte) set_pte(ptep, pte)
> #endif
> 
> which would avoid having to update the other platforms and woud allow a
> gradual transition.

In order for it to be useful, every set_pte() call has to get the
new args.  If there are exceptions, then it doesn't work out cleanly.

All of the call sites of set_pte() have the information available,
so implementing it properly in all cases is nearly trivial, it's
just a lot of busy work.  So we should get it over with now.

I did all of the generic code, it's just each platform's code that
needs updating.

And BTW it's not just set_pte(), it's also pte_clear() and some of
the other routines that need the added mm and address args.
