From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Thu, 13 Apr 2017 23:44:56 +0000
Subject: Re: [PATCH v2] kbuild: Consolidate header generation from ASM offset information
Message-Id: <CAK7LNAQcPmL9wscO2NY78zc8q+07ck8LucZDUUPjzAYxcyK10g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170412194352.108290-1-mka@chromium.org>
In-Reply-To: <20170412194352.108290-1-mka@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Michal Marek <mmarek@suse.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kiszka <jan.kiszka@siemens.com>, Kieran Bingham <kieran.bingham@linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Grant Grundler <grundler@chromium.org>, Greg Hackmann <ghackmann@google.com>, Michael Davidson <md@google.com>

2017-04-13 4:43 GMT+09:00 Matthias Kaehlcke <mka@chromium.org>:
> Largely redundant code is used in different places to generate C headers
> from offset information extracted from assembly language output.
> Consolidate the code in Makefile.lib and use this instead.
>
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>


Applied to linux-kbuild/kbuild.
Thanks!


-- 
Best Regards
Masahiro Yamada
