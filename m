From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 02 Sep 2004 21:55:00 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <20040902145500.271ae676.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040827172337.638275c3.davem@davemloft.net>
	<20040827173641.5cfb79f6.akpm@osdl.org>
	<20040828010253.GA50329@muc.de>
	<20040827183940.33b38bc2.akpm@osdl.org>
	<16687.59671.869708.795999@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0408272021070.16607@schroedinger.engr.sgi.com>
	<20040827204241.25da512b.akpm@osdl.org>
	<Pine.LNX.4.58.0408272121300.16949@schroedinger.engr.sgi.com>
	<20040827223954.7d021aac.akpm@osdl.org>
	<1094012028.6539.320.camel@gaston>
	<20040902212634.GJ16175@wotan.suse.de>
In-Reply-To: <20040902212634.GJ16175@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: benh@kernel.crashing.org, akpm@osdl.org, clameter@sgi.com, paulus@samba.org, ak@muc.de, ak@suse.de, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Thu, 2 Sep 2004 23:26:34 +0200
Andi Kleen <ak@suse.de> wrote:

> I would do atomic64 on 64bit archs only and then do a wrapper 
> somewhere that defines atomiclongt based on BITSPERLONG 

We do have CONFIG_64BIT, might as well use it.
