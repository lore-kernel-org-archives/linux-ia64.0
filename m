From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 18 Jan 2021 20:37:30 +0000
Subject: Re: [GIT PULL] ia64: fix build regression
Message-Id: <388d1fc5-40fa-2f9e-3302-111c618941bd@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210118113411.GM1106298@kernel.org>
In-Reply-To: <20210118113411.GM1106298@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 1/18/21 12:34 PM, Mike Rapoport wrote:
> The following changes since commit 7c53f6b671f4aba70ff15e1b05148b10d58c2837:
> 
>   Linux 5.11-rc3 (2021-01-10 14:34:50 -0800)
> 
> are available in the Git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/rppt/memblock tags/fixes-2021-01-18
> 
> for you to fetch changes up to 32c2bc8f2d855d4415c9a05b727e34649397bfbe:
> 
>   ia64: fix build failure caused by memory model changes (2021-01-17 13:31:09 +0200)
> 
> ----------------------------------------------------------------
> ia64: fix build failure caused by memory model changes
> 
> ----------------------------------------------------------------
> Mike Rapoport (1):
>       ia64: fix build failure caused by memory model changes
> 
>  arch/ia64/include/asm/sparsemem.h | 1 +
>  1 file changed, 1 insertion(+)

Since I just read this sensationalist article on Phoronix [1], I just haven't gotten
around to test 5.11 for ia64 as I was currently busy with testing all pending patches
for SH.

I will be getting around testing the ia64 build and also bisect that one issue with
the hpsa driver which was no longer usable after some change in the mm tree.

Adrian

> [1] https://www.phoronix.com/scan.php?page=news_item&px=Itanium-IA64-Linux-5.11-Broken

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
