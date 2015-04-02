From: Michal Marek <mmarek@suse.cz>
Date: Thu, 02 Apr 2015 15:27:49 +0000
Subject: Re: [PATCH 0/4] kbuild: refactor Makefile inclusion
Message-Id: <551D5FF5.7070503@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427456618-23830-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1427456618-23830-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild@vger.kernel.org
Cc: linux-mips@linux-mips.org, Tony Luck <tony.luck@intel.com>, x86@kernel.org, linux-ia64@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, Jeff Dike <jdike@addtoit.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, Richard Weinberger <richard@nod.at>, user-mode-linux-user@lists.sourceforge.net, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, linux-arm-kernel@lists.infradead.org

On 2015-03-27 12:43, Masahiro Yamada wrote:
> Masahiro Yamada (4):
>   kbuild: use relative path to include Makefile
>   kbuild: use relative path more to include Makefile
>   kbuild: include $(src)/Makefile rather than $(obj)/Makefile
>   kbuild: ia64: use $(src)/Makefile.gate rather than particular path

Applied to kbuild.git#kbuild.

Michal

