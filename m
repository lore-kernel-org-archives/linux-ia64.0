From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Fri, 20 Sep 2013 14:39:32 +0000
Subject: Re: [PATCH] Fixed typo on word accounting in kprobes.c in mutliple architectures
Message-Id: <20130920143932.GA4017@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130918210351.GA13811@gmail.com>
In-Reply-To: <20130918210351.GA13811@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anoop Thomas Mathew <atm@profoundis.com>
Cc: vgupta@synopsys.com, tony.luck@intel.com, davem@davemloft.net, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, Jiri Kosina <trivial@kernel.org>

On Thu, Sep 19, 2013 at 02:33:58AM +0530, Anoop Thomas Mathew wrote:
> Signed-off-by: Anoop Thomas Mathew <atm@profoundis.com>
> ---
>  arch/arc/kernel/kprobes.c     |    2 +-
>  arch/ia64/kernel/kprobes.c    |    2 +-
>  arch/powerpc/kernel/kprobes.c |    2 +-
>  arch/s390/kernel/kprobes.c    |    2 +-
>  arch/sparc/kernel/kprobes.c   |    2 +-
>  5 files changed, 5 insertions(+), 5 deletions(-)

Please send trivial typo fixes to Jiri Kosina <trivial@kernel.org>.
See "TRIVIAL PATCHES" in MAINTAINERS. Thanks!

