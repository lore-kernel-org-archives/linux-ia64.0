From: "David S. Miller" <davem@davemloft.net>
Date: Sat, 28 Aug 2004 00:23:37 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <20040827172337.638275c3.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
	<20040815165827.0c0c8844.davem@redhat.com>
	<Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
	<20040815185644.24ecb247.davem@redhat.com>
	<Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
	<20040816143903.GY11200@holomorphy.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B679F@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67A9@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67B4@mtv-atc-605e--n.corp.sgi.com>
	<Pine.LNX.4.58.0408271616001.14712@schroedinger.engr.sgi.com>
	<20040827233602.GB1024@wotan.suse.de>
	<Pine.LNX.4.58.0408271717400.15597@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408271717400.15597@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, akpm@osdl.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Fri, 27 Aug 2004 17:19:11 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> That is still 2^(32+12) = 2^44 = 16TB.

It's actually:

	2 ^ (31 + PAGE_SHIFT)

'31' because atomic_t is 'signed' and PAGE_SHIFT should
be obvious.

Christoph definitely has a point, this is even more virtual space
than most of the 64-bit platforms even support.  (Sparc64 is
2^43 and I believe ia64 is similar)  and this limit actually
mostly comes from the 3-level page table limits.

