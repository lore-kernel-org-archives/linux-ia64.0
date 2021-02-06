From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sat, 06 Feb 2021 16:07:21 +0000
Subject: Re: [PATCH] ia64: Fix style guide breakage
Message-Id: <a3215a2b-76d3-6285-8072-160a905de362@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210205220618.611388-1-enbyamy@gmail.com>
In-Reply-To: <20210205220618.611388-1-enbyamy@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amy Parker <enbyamy@gmail.com>, schnelle@linux.ibm.com, corbet@lwn.net, mchehab+huawei@kernel.org, tsbogend@alpha.franken.de
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Amy!

On 2/5/21 11:06 PM, Amy Parker wrote:
> Some statements do not have proper spacing between their C
> keywords (commonly if and for) throughout files in the ia64 tree.
> This patch corrects this to follow the kernel code style guide.
> 
> Signed-off-by: Amy Parker <enbyamy@gmail.com>

I never noticed. Does the kernel coding style guideline actually require
space after "for" and "if" and similar statements but not before function
names?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
