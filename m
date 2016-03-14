From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 14 Mar 2016 00:39:42 +0000
Subject: Re: [PATCH] kbuild: drop FORCE from PHONY targets
Message-Id: <CALCETrVqzidL7SXsCVm8wWrcQMR9dFOLGnDtC-eEYMO4a+yszA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1457828035-30584-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1457828035-30584-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@arm.linux.org.uk>, Michal Marek <mmarek@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, Nathan Lynch <nathan_lynch@mentor.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Mar 12, 2016 4:14 PM, "Masahiro Yamada"
<yamada.masahiro@socionext.com> wrote:
>
> These targets are marked as PHONY.  No need to add FORCE to their
> dependency.

If this is, in fact, correct, can you update
Documentation/kbuild/makefiles.txt as well?

Thanks,
Andy
