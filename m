From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 02 Sep 2004 21:07:59 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <20040902140759.5f1003d5.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
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
	<20040902131057.0341e337.davem@davemloft.net>
	<Pine.LNX.4.58.0409021358540.28182@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0409021358540.28182@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: benh@kernel.crashing.org, akpm@osdl.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Thu, 2 Sep 2004 14:02:47 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> I have the similar issues with the page scalability patch. Should I not do
> the legacy thing for platforms that do not have atomic pte operations?
> '

I think your situation is different.  The set_pte() changes are modifying
the arguments of an existing interface.

Your changes are adding support for taking advantage of a facility
that may or may not exist on a platform.
