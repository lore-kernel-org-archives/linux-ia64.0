From: Ard Biesheuvel <ardb@kernel.org>
Date: Thu, 16 Feb 2023 18:32:03 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <CAMj1kXG5ufjnZGX=i92REDTayrYEKu0uVCdMB5X5JkNfAX4peA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Feb 2023 at 18:43, Pedro Miguel Justo <pmsjt@texair.net> wrote:
>
> Hi Ard.
>
> John is not the "only remaining user". I also reported the problem. I am sorry I don't update the kernel every month. Yes there might have been more than 30 days between updates.
>

Thanks for the report.

Apologies if that sounded a bit callous but it does help get some
clarity regarding the ia64 situation. Essentially, we have a very
small number of downstream users but no dedicated developers or
maintainers. That is still not a great situation.

> I'd prefer if we don't remove the Itanium McKinley+ support but I'll understand if it must.
>

If you are invested in keeping Itanium alive, how much effort would
you be willing to spend yourself on testing and reviewing Itanium
changes?
