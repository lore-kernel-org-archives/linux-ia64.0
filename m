From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 15 Feb 2023 10:19:18 +0000
Subject: Re: [RFC PATCH 2/5] kernel: Drop IA64 support from sig_fault handlers
Message-Id: <ea12dd12-db17-44a8-8c29-6b0a129f355d@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
 <20230215100008.2565237-3-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-3-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>, linux-kernel@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Wed, Feb 15, 2023, at 11:00, Ard Biesheuvel wrote:
> Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
> ---
>  include/linux/sched/signal.h | 17 ++++---------
>  kernel/signal.c              | 25 ++++----------------
>  2 files changed, 9 insertions(+), 33 deletions(-)

The patch looks good, but I'd suggest adding a oneline description
referencing that ia64 as a whole is removed.

I see that you created a couple of patches looking for __ia64__
but not CONFIG_IA64. If we get consensus on patch 1, we should
do that as well, let me know if you you want to add those or
would like me to help here.

I can probably do the same recursive check for removed Kconfig
options that I used for finding dead code after the boardfile
removal.

     Arnd
