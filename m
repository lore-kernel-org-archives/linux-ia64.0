From: "stephane eranian" <eranian@googlemail.com>
Date: Wed, 12 Dec 2007 16:18:20 +0000
Subject: Re: [PATCH 1/3] Rename TIF_PERFMON_WORK back to TIF_NOTIFY_RESUME
Message-Id: <7c86c4470712120818k37f55cfavafe6cf6ede0c0684@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959881.6586.6.camel@elijah.suse.cz>
In-Reply-To: <1196959881.6586.6.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Petr,


On Dec 12, 2007 12:07 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
>
> I'm making a mental note to review this later for optimization. AFAICS
> fetching the pfm_needs_checking field is not too costly, but of course
> it's an extra memory reference (and possibly a cache miss).
>
Yes. The TIF flag has the advantage of being in the same cacheline.

> On a related note, I think that we should be able to use all 8 bits for
> pending work TIF_ bits despite the brain-damaged sign extension in "and
> imm8", but I don't have the time now to go through all uses of the
> thread flags in assembly. Not really sure if it's worth adding one TIF_
> bit, because we'll pretty certainly need one more bit in the future...
>
Yes, I ran into that difficulty myself when I tried adding my TIF flag.
Not sure how you could work around it.

> Anyway, I'd like to push the changes to ptrace first, because that's
> currently broken.
That's fine. What you have right now show work.

thanks.
