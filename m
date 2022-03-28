From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 28 Mar 2022 20:07:31 +0000
Subject: Re: [PATCH 1/2] ia64: topology: Fix an error handling path in cache_add_dev()
Message-Id: <a6640ec8-0f1c-0c97-2550-84871ad95051@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <452b20c160a20754022407acefd2abb170f43d14.1648494330.git.christophe.jaillet@wanadoo.fr>
 <facd6471-4c4f-ff5a-e81f-38acd855eb8d@physik.fu-berlin.de>
 <78d00a13-3cee-386c-07f1-8d16a24e4e67@wanadoo.fr>
In-Reply-To: <78d00a13-3cee-386c-07f1-8d16a24e4e67@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, Tony Luck <tony.luck@intel.com>, Zhang Yanmin <yanmin.zhang@intel.com>
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hi Christophe!

On 3/28/22 21:45, Christophe JAILLET wrote:
> For the other patch, it is just a clean-up. Based on Wikipedia, IA64 is
> discontinued, so such clean-up does not make that much sense either.
> (on the other hand, it should be eay to review and apply :) )

ia64 is still supported in Debian and Gentoo, so any kind of clean-up and
improvement of the kernel code is very welcome.

> I don't think you need to spent time on it. Sorry for the noise.

You didn't make any noise. If you have some improvements, I'm happy to test
them on my ia64 test system.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
