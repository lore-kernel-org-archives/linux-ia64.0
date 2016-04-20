From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Wed, 20 Apr 2016 08:56:31 +0000
Subject: Re: [PATCH] kbuild: drop redundant "PHONY += FORCE"
Message-Id: <CAK7LNATv51PRc9bGU7Q8_oTk9=C5ryfu7vMsKbG5drcgVbf1-Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460081770-29437-1-git-send-email-yamada.masahiro@socionext.com>
	<20160420084710.GF15339@pobox.suse.cz>
In-Reply-To: <20160420084710.GF15339@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Marek <mmarek@suse.cz>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

Hi Michal,

2016-04-20 17:47 GMT+09:00 Michal Marek <mmarek@suse.cz>:
> On Fri, Apr 08, 2016 at 11:16:10AM +0900, Masahiro Yamada wrote:
>> "PHONY += FORCE" is already cared by scripts/Makefile.build,
>> which these files are included from.
>
> arch/ia64/Makefile is in fact included via the main Makefile. But this
> one also has the PHONY += FORCE statement. Maybe we should initialize
> PHONY with FORCE in Kbuild.include. Nevertheless, this patch is correct.
>
> Michal

Ah, right.

If it is not too late and you do not mind,
could you rephrase the git-log?

Like this?

----------------------->8------------------------------------
"PHONY += FORCE" is already cared by scripts/Makefile.build or the
top level Makefile, which these files are included from.
-----------------------8<------------------------------------



-- 
Best Regards
Masahiro Yamada
