From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 11 Oct 2018 07:32:57 +0000
Subject: Re: [PATCH v3 4/7] ia64: replace the system call table entries from entry.S
Message-Id: <CAK8P3a2JdFnAQcZ9YSOkEC_Od4QeLLP0RcWkte5MHC6VSXi0qQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1539231895-4118-1-git-send-email-firoz.khan@linaro.org> <1539231895-4118-5-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1539231895-4118-5-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Firoz Khan <firoz.khan@linaro.org>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, gregkh <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

On Thu, Oct 11, 2018 at 6:25 AM Firoz Khan <firoz.khan@linaro.org> wrote:
>
> In IA64, system call table entries are the part of entry.S file.
> We need to keep it in a separate file so that one of the patch in
> this patch series contains a system call table generation script
> which can separately handle system call table entries.
>
> Replaced the system call table from entry.S to syscall_table.S,
> this is a new file. This change will unify the implementation
> across all the architecture and to simplify the implementation for
> system call table generation using the script.
>
> Signed-off-by: Firoz Khan <firoz.khan@linaro.org>
> ---
>  arch/ia64/kernel/entry.S         | 333 +-------------------------------------
>  arch/ia64/kernel/syscall_table.S | 334 +++++++++++++++++++++++++++++++++++++++

According to the discussion we had on the same patch for parisc,
I suppose we can skip this one as well now, and just remove the
entries when the generated table is added.

       Arnd
