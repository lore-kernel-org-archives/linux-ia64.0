From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 19 Nov 2003 22:54:14 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106928289216095@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew wrote (on the linux-ia64 list):
>> Why u16 rather than u32?

On Wed, Nov 19, 2003 at 01:45:30PM -0800, Paul Jackson wrote:
> You'd probably have to ask whomever wrote that part in the first place.
> I'd guess Jack was using u16 because it was already there.
> My take - we should:
>  1) change the loop to u32,
>  2) add a separator character, say comma ',', between u32 words, and
>  3) drop the zero %04x fill.

It was to silence a warning. You'll have write your own to replace
the fix now in -mm if this is what you really want.


-- wli
