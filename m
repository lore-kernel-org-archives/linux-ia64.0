From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Mon, 28 Mar 2022 19:45:14 +0000
Subject: Re: [PATCH 1/2] ia64: topology: Fix an error handling path in cache_add_dev()
Message-Id: <78d00a13-3cee-386c-07f1-8d16a24e4e67@wanadoo.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <452b20c160a20754022407acefd2abb170f43d14.1648494330.git.christophe.jaillet@wanadoo.fr>
 <facd6471-4c4f-ff5a-e81f-38acd855eb8d@physik.fu-berlin.de>
In-Reply-To: <facd6471-4c4f-ff5a-e81f-38acd855eb8d@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Tony Luck <tony.luck@intel.com>, Zhang Yanmin <yanmin.zhang@intel.com>
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Le 28/03/2022 à 21:16, John Paul Adrian Glaubitz a écrit :
> Hi Christophe!
> 
> On 3/28/22 21:07, Christophe JAILLET wrote:
>> If kobject_init_and_add()fails, kobject_put() needs to be called.
>> Add the missing call which is already there a few lines below in another
>> error handling path.
>>
>> Fixes: f19180056ea0 ("[IA64] Export cpu cache info by sysfs")
>> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> 
> Thanks for your patches. There is currently no maintainer for ia64, so the patches
> would have to go through Andrew Morton's tree.
> 
> However, I can test the patches and verify they don't break anything.
> 
> Adrian
> 

Hi,

digging deeper for other potential same issues in other file, I don't 
think that this patch is needed, and I don't think that it fixes anything.

The "name" of this kobject is "%s", "cache".
So nothing needs to be freed for that because kstrdup_const() will be used.

This kobject has no .release function.

If the add() part of kobject_init_and_add(), then 'state_in_sysfs' will 
still be 0, so nothing needs to be released for that either.


So, adding a kobject_put() would just be a no-op here (if I understand 
correctly).

I've been puzzled by the kobject_put() later, but in this case, _add() 
has already succeeded and state_in_sysfs=1 and the call is needed.


For the other patch, it is just a clean-up. Based on Wikipedia, IA64 is 
discontinued, so such clean-up does not make that much sense either.
(on the other hand, it should be eay to review and apply :) )


I don't think you need to spent time on it. Sorry for the noise.

CJ
