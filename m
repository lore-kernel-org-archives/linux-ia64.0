From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 17 Aug 2004 15:37:15 +0000
Subject: Re: page fault fastpath patch v2: fix race conditions, stats for 8,32 and 512 cpu SMP
Message-Id: <20040817163715.A23196@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <20040815130919.44769735.davem@redhat.com> <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com> <20040815165827.0c0c8844.davem@redhat.com> <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com> <20040815185644.24ecb247.davem@redhat.com> <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com> <20040816143903.GY11200@holomorphy.com> <Pine.LNX.4.58.0408170804430.8365@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408170804430.8365@schroedinger.engr.sgi.com>; from clameter@sgi.com on Tue, Aug 17, 2004 at 08:28:44AM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 17, 2004 at 08:28:44AM -0700, Christoph Lameter wrote:
> This is the second release of the page fault fastpath path. The fast path
> avoids locking during the creation of page table entries for anonymous
> memory in a threaded application running on a SMP system. The performance
> increases significantly for more than 4 threads running concurrently.

Please reformat your patch according to Documentation/CodingStyle
(or just look at the surrounding code..).

Also you're duplicating far too much code of the regular pagefault code,
this probably wants some inlined helpers.

Your ptep_lock should be called ptep_trylock.

