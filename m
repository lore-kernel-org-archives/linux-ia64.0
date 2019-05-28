From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 28 May 2019 16:20:56 +0000
Subject: Re: [PATCH - Linus please apply] ia64: fix build errors by exporting paddr_to_nid()
Message-Id: <CAHk-=whaNQSnV3Mv_-T8jLmPeHQUTZieg+ZYhyUufW4wrPymfw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190528161430.27697-1-tony.luck@intel.com>
In-Reply-To: <20190528161430.27697-1-tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 28, 2019 at 9:14 AM Tony Luck <tony.luck@intel.com> wrote:
>
> Fix build errors on ia64 when DISCONTIGMEM=y and NUMA=y by
> exporting paddr_to_nid().

Applied.

Just out of curiosity, what caused this error? It doesn't _look_ new,
just judging from the patch itself. Is this just a configuration that
nobody has noticed before, or something else that changed that caused
it to happen now?

                Linus
