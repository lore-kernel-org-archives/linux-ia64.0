From: Michal Marek <mmarek@suse.cz>
Date: Wed, 20 Apr 2016 08:47:10 +0000
Subject: Re: [PATCH] kbuild: drop redundant "PHONY += FORCE"
Message-Id: <20160420084710.GF15339@pobox.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460081770-29437-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1460081770-29437-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kbuild@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Fenghua Yu <fenghua.yu@intel.com>, linux-arm-kernel@lists.infradead.org

On Fri, Apr 08, 2016 at 11:16:10AM +0900, Masahiro Yamada wrote:
> "PHONY += FORCE" is already cared by scripts/Makefile.build,
> which these files are included from.

arch/ia64/Makefile is in fact included via the main Makefile. But this
one also has the PHONY += FORCE statement. Maybe we should initialize
PHONY with FORCE in Kbuild.include. Nevertheless, this patch is correct.

Michal
