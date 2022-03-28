From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 28 Mar 2022 19:16:21 +0000
Subject: Re: [PATCH 1/2] ia64: topology: Fix an error handling path in cache_add_dev()
Message-Id: <facd6471-4c4f-ff5a-e81f-38acd855eb8d@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <452b20c160a20754022407acefd2abb170f43d14.1648494330.git.christophe.jaillet@wanadoo.fr>
In-Reply-To: <452b20c160a20754022407acefd2abb170f43d14.1648494330.git.christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, Tony Luck <tony.luck@intel.com>, Zhang Yanmin <yanmin.zhang@intel.com>
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hi Christophe!

On 3/28/22 21:07, Christophe JAILLET wrote:
> If kobject_init_and_add()fails, kobject_put() needs to be called.
> Add the missing call which is already there a few lines below in another
> error handling path.
> 
> Fixes: f19180056ea0 ("[IA64] Export cpu cache info by sysfs")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Thanks for your patches. There is currently no maintainer for ia64, so the patches
would have to go through Andrew Morton's tree.

However, I can test the patches and verify they don't break anything.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
