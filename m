From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Date: Mon, 20 Jun 2022 19:21:12 +0000
Subject: Re: [alobakin:bitops 3/7] block/elevator.c:222:9: sparse: sparse: cast from restricted req_flags_t
Message-Id: <20220620192112.ghyegqvtj3ud7zla@mail>
List-Id: <linux-ia64.vger.kernel.org>
References: <202206191726.wq70mbMK-lkp@intel.com>
 <20220617144031.2549432-1-alexandr.lobakin@intel.com>
 <20220620135146.2628908-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220620135146.2628908-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, kbuild-all@lists.01.org, kernel test robot <lkp@intel.com>

On Mon, Jun 20, 2022 at 03:51:46PM +0200, Alexander Lobakin wrote:
> From: kernel test robot <lkp@intel.com>
> Date: Sun, 19 Jun 2022 17:20:05 +0800
> 
> Also, could someone please help me with this? I don't get what went
> wrong with sparse, it's not even some new code, just moving old
> stuff.

Hi,

The first sparse's warnings (sparse: preprocessor token __ATOMIC_*) are already
fixed (and most probably, the bots have already taken the fix).
I'm working on the second ones (sparse: unreplaced symbol).

-- Luc (Sparse's maintainer)
