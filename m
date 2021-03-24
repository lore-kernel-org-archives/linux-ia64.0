From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 24 Mar 2021 22:39:34 +0000
Subject: Re: [PATCH] ia64: mca: allocate early mca with GFP_ATOMIC
Message-Id: <20210324153934.963ac2cb8f44a4e529016612@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210315085045.204414-1-slyfox@gentoo.org>
        <f351183c-7d70-359f-eed7-4d1722cf41c5@physik.fu-berlin.de>
        <20210323174724.78b61c02@sf>
        <4f7ccc08-7355-63a0-7239-16a5fb29207f@physik.fu-berlin.de>
In-Reply-To: <4f7ccc08-7355-63a0-7239-16a5fb29207f@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 24 Mar 2021 11:20:45 +0100 John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:

> >> #NEXT_PATCHES_START mainline-later (next week, approximately)
> >> ia64-mca-allocate-early-mca-with-gfp_atomic.patch
> 
> Great, thanks. We're still missing Valentin's patch for the NUMA enumeration issue
> though. Should Valentin send the patch again with Andrew CC'ed?

I subscribed to linux-ia64 today, so I can go in there to find things. 
But if there's anything presently outstanding, please do resend.

I presently have

module-remove-duplicate-include-in-arch-ia64-kernel-heads.patch
ia64-kernel-few-typos-fixed-in-the-file-fsyss.patch
ia64-include-asm-minor-typo-fixes-in-the-file-pgtableh.patch
ia64-ensure-proper-numa-distance-and-possible-map-initialization.patch
ia64-drop-unused-ia64_fw_emu-ifdef.patch
