From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 May 2019 01:44:23 +0000
Subject: Re: [PATCH: Linus please apply] ia64: Make sure that we have a mmiowb function real early
Message-Id: <CAHk-=wgLK+FzuS-7QfaeZQnF8ZXiqHpf8Zh3e6L+Ve+zO5fKHQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190516010414.30623-1-tony.luck@intel.com>
In-Reply-To: <20190516010414.30623-1-tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 15, 2019 at 6:04 PM Tony Luck <tony.luck@intel.com> wrote:
>
> Statically initialize the mmiowb field of machvec so that we
> won't die with a call through a NULL pointer. This should be
> safe because we do the real initialization of machvec before
> bringing up any addtional CPUs or doing any I/O.

Thanks, applied.

            Linus
