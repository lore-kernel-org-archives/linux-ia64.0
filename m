From: Andi Kleen <ak@muc.de>
Date: Mon, 30 Aug 2004 17:05:35 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64 support added
Message-Id: <20040830170535.GA38640@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040828010253.GA50329@muc.de> <20040827183940.33b38bc2.akpm@osdl.org> <16687.59671.869708.795999@cargo.ozlabs.ibm.com> <Pine.LNX.4.58.0408272021070.16607@schroedinger.engr.sgi.com> <20040827204241.25da512b.akpm@osdl.org> <Pine.LNX.4.58.0408272121300.16949@schroedinger.engr.sgi.com> <20040827223954.7d021aac.akpm@osdl.org> <Pine.LNX.4.58.0408272256030.17485@schroedinger.engr.sgi.com> <20040827230637.6b3eb2ac.akpm@osdl.org> <20040830170211.GB7718@MAIL.13thfloor.at>
In-Reply-To: <20040830170211.GB7718@MAIL.13thfloor.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, paulus@samba.org, davem@davemloft.net, ak@suse.de, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Mon, Aug 30, 2004 at 07:02:11PM +0200, Herbert Poetzl wrote:
> 
> hmm, please correct me, but last time I checked
> atomic_add_return() wasn't even available for i386
> for example ...

There is a patch pending to add it.


-Andi
