From: Andrew Morton <akpm@osdl.org>
Date: Sat, 28 Aug 2004 03:42:41 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <20040827204241.25da512b.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
	<20040816143903.GY11200@holomorphy.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B679F@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67A9@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67B4@mtv-atc-605e--n.corp.sgi.com>
	<Pine.LNX.4.58.0408271616001.14712@schroedinger.engr.sgi.com>
	<20040827233602.GB1024@wotan.suse.de>
	<Pine.LNX.4.58.0408271717400.15597@schroedinger.engr.sgi.com>
	<20040827172337.638275c3.davem@davemloft.net>
	<20040827173641.5cfb79f6.akpm@osdl.org>
	<20040828010253.GA50329@muc.de>
	<20040827183940.33b38bc2.akpm@osdl.org>
	<16687.59671.869708.795999@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0408272021070.16607@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408272021070.16607@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: paulus@samba.org, ak@muc.de, davem@davemloft.net, ak@suse.de, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

Christoph Lameter <clameter@sgi.com> wrote:
>
>  So I think the move to atomic for rss acceptable?

Short-term, yes.  Longer term (within 12 months), no - 50-bit addresses on
power5 will cause it to overflow.

We may as well fix it up now, but let's set that aside during consideration
of the rest of your patch.

