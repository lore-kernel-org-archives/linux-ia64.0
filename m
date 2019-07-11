From: Christopher Lameter <cl@linux.com>
Date: Thu, 11 Jul 2019 07:54:42 +0000
Subject: Re: [RFC PATCH] mm: remove quicklist page table caches
Message-Id: <0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190711030339.20892-1-npiggin@gmail.com>
In-Reply-To: <20190711030339.20892-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org

On Thu, 11 Jul 2019, Nicholas Piggin wrote:

> Remove page table allocator "quicklists". These have been around for a
> long time, but have not got much traction in the last decade and are
> only used on ia64 and sh architectures.

I also think its good to remove this code. Note sure though if IA64
may still have a need of it. But then its not clear that the IA64 arch is
still in use. Is it still maintained?

> Also it might be better to instead make more general improvements to
> page allocator if this is still so slow.

Well yes many have thought so and made attempts to improve the situation
which generally have failed. But even the fast path of the page allocator
seems to bloat more and more. The situation is deteriorating instead of
getting better and as a result lots of subsystems create their own caches
to avoid the page allocator.
