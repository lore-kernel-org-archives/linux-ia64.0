From: Andi Kleen <ak@muc.de>
Date: Sun, 19 Sep 2004 12:11:55 +0000
Subject: Re: page fault scalability patch V8: [4/7] universally available cmpxchg on i386
Message-Id: <20040919121155.GA58884@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <B6E8046E1E28D34EB815A11AC8CA312902CD3243@mtv-atc-605e--n.corp.sgi.com> <Pine.LNX.4.58.0409181627300.24054@schroedinger.engr.sgi.com> <200409191430.37444.vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200409191430.37444.vda@port.imtp.ilyichevsk.odessa.ua>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, benh@kernel.crashing.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Sun, Sep 19, 2004 at 02:30:37PM +0300, Denis Vlasenko wrote:
> Far too large for inline

It's much smaller than it looks - the switch will be optimized away by the
compiler. For the X86_CMPXCHG case it is even a single instruction.
For the other case it should be < 10 instructions, which is still reasonable.

-Andi
