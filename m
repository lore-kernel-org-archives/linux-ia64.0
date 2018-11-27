From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Nov 2018 02:16:41 +0000
Subject: Re: [PATCH] ia64: export node_distance function
Message-Id: <CAHk-=wi4JV5dRLRrHmus0XaXu7YTszdUWEKQBVdx7taTBFg-eg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181103183716.28841-1-mb@lightnvm.io>
In-Reply-To: <20181103183716.28841-1-mb@lightnvm.io>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 26, 2018 at 11:27 AM Tony Luck <tony.luck@intel.com> wrote:
>
> The numa_slit variable used by node_distance is available to a
> module as long as it is linked at compile-time. However, it is
> not available to loadable modules. Leading to errors such as:
[...]

Tony: Just checking - you aren't planning on doing a git pull request,
and want me to apply this directly as a patch?

             Linus
