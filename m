From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 23 Jul 2012 14:54:43 +0000
Subject: Re: [PATCH -next] random: Remove remaining relicts of rand_initialize_irq()
Message-Id: <CACRpkdbgt9kNTbF6YfL1rEbwWLA85a6b4crsOzTfedM+3KJBbA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1342524793-2522-1-git-send-email-sedat.dilek@gmail.com>
	<20120717171251.GD6049@thunk.org>
	<CACRpkdZe48FrDJx1p8ojfqwVBE95hSJipE8rViAi=E28uumYOQ@mail.gmail.com>
	<20120717214219.GF6049@thunk.org>
In-Reply-To: <20120717214219.GF6049@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Theodore Ts'o <tytso@mit.edu>, Linus Walleij <linus.walleij@linaro.org>, Sedat Dilek <sedat.dilek@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Linus Walleij <linus.walleij@stericsson.com>, Samuel Ortiz <sameo@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Jul 17, 2012 at 11:42 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Tue, Jul 17, 2012 at 08:57:19PM +0200, Linus Walleij wrote:
>> So the IRQ will be auto-sampled now or something?
>>
>> Sorry for not quite following, which commit do I look at to
>> understand this now...
>
> Yes, there was a huge discussion on LKML about two weeks ago.  The
> key commit that will be going in during the next merge window is:
>
> http://git.kernel.org/?p=linux/kernel/git/tytso/random.git;a=commitdiff;hw5f4b297b780601e61787b766f306ed3e1d23eb

I get it now, after checking the commit and reading the LWN
article. It's all looking good,
Acked-by: Linus Walleij <linus.walleij@linaro.org>

Yours,
Linus Walleij
