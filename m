From: Michal Marek <mmarek@suse.com>
Date: Wed, 20 Apr 2016 08:29:11 +0000
Subject: Re: [PATCH] kbuild: drop FORCE from PHONY targets
Message-Id: <57173DD7.6020601@suse.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1457828035-30584-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1457828035-30584-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Nathan Lynch <nathan_lynch@mentor.com>, linux-ia64@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-arm-kernel@lists.infradead.org

Dne 13.3.2016 v 01:13 Masahiro Yamada napsal(a):
> These targets are marked as PHONY.  No need to add FORCE to their
> dependency.
> 
> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> ---
> 
>  Makefile                     | 8 ++++----
>  arch/arm/vdso/Makefile       | 2 +-
>  arch/ia64/Makefile           | 4 ++--
>  arch/x86/entry/vdso/Makefile | 4 ++--
>  4 files changed, 9 insertions(+), 9 deletions(-)

Applied to kbuild.git#kbuild now, sorry for the delay.

Michal

