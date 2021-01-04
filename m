From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 04 Jan 2021 09:32:53 +0000
Subject: Re: [PATCH] ia64: fix xchg() warning
Message-Id: <CAK8P3a3zDB5wh-bdg+fq6nvg9gHrESFhhgss4f47VJ1JOvoE1Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210104085806.4176886-1-arnd@kernel.org> <ad54481b-15da-e795-0c1a-bd54d3e8ab87@physik.fu-berlin.de>
In-Reply-To: <ad54481b-15da-e795-0c1a-bd54d3e8ab87@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jan 4, 2021 at 10:06 AM John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
>
> Hi Arnd!
>
> On 1/4/21 9:58 AM, Arnd Bergmann wrote:
> > Change it to a compound expression like the other architectures have
> > to get a clean defconfig build.
>
> Slightly OT: Has your other fix for the timer regression on ia64 already been
> merged? I can test this patch later today.

I have not received any reply from the ia64 maintainers, I assume they were
both out of office for Christmas.

      Arnd
