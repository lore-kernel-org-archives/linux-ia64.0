From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 27 Jan 2009 22:47:30 +0000
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Message-Id: <497F8F02.9000603@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200901271213.18605.rusty@rustcorp.com.au>	<497E705B.5000302@kernel.org>	<alpine.DEB.1.10.0901271506580.3114@qirst.com> <20090127.134747.153565246.davem@davemloft.net>
In-Reply-To: <20090127.134747.153565246.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: cl@linux-foundation.org, tj@kernel.org, rusty@rustcorp.com.au, mingo@elte.hu, herbert@gondor.apana.org.au, akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com, ebiederm@xmission.com, travis@sgi.com, linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com, netdev@vger.kernel.org, mathieu.desnoyers@polymtl.ca, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

David Miller wrote:
> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Tue, 27 Jan 2009 15:08:57 -0500 (EST)
> 
> 
>>On Tue, 27 Jan 2009, Tejun Heo wrote:
>>
>>
>>>>later). That's because they use TLB tricks for a static 64k per-cpu
>>>>area, but this doesn't scale.  That might not be vital: abandoning
>>>>that trick will mean they can't optimise read_percpu/read_percpu_var
>>>>etc as much.
>>
>>Why wont it scale? this is a separate TLB entry for each processor.
> 
> 
> The IA64 per-cpu TLB entry only covers 64k which makes use of it for
> dynamic per-cpu stuff out of the question.  That's why it "doesn't
> scale"

I was asking around, and was told that on IA64 *harware* at least, in addition to 
supporting multiple page sizes (up to a GB IIRC), one can pin up to 8 or perhaps 
1/2 the TLB entries.

So, in theory if one were so inclined the special pinned per-CPU entry could 
either be more than one 64K entry, or a single, rather larger entry.

As a sanity check, I've cc'd linux-ia64.

rick jones
