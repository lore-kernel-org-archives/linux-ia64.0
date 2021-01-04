From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 04 Jan 2021 09:06:27 +0000
Subject: Re: [PATCH] ia64: fix xchg() warning
Message-Id: <ad54481b-15da-e795-0c1a-bd54d3e8ab87@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210104085806.4176886-1-arnd@kernel.org>
In-Reply-To: <20210104085806.4176886-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Arnd!

On 1/4/21 9:58 AM, Arnd Bergmann wrote:
> Change it to a compound expression like the other architectures have
> to get a clean defconfig build.

Slightly OT: Has your other fix for the timer regression on ia64 already been
merged? I can test this patch later today.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
