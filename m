From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 14 Sep 2021 14:14:58 +0000
Subject: Re: [PATCH] arch: remove unused function syscall_set_arguments()
Message-Id: <CAK8P3a3gKeZhvYv9CyVQS4d2=XhOQPQH8Jvjki_FzLZexa4oVA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210913222447.4112-1-pcc@google.com>
In-Reply-To: <20210913222447.4112-1-pcc@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Collingbourne <pcc@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arch <linux-arch@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Sep 14, 2021 at 12:24 AM Peter Collingbourne <pcc@google.com> wrote:
>
> This function appears to have been unused since it was first introduced in
> commit 828c365cc8b8 ("tracehook: asm/syscall.h").
>
> Signed-off-by: Peter Collingbourne <pcc@google.com>
> Link: https://linux-review.googlesource.com/id/I8ce04f002903a37c0b6c1d16e9b2a3afa716c097

Looks good to me, applied to the asm-generic tree.

        Arnd
