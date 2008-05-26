From: "Luming Yu" <luming.yu@gmail.com>
Date: Mon, 26 May 2008 01:30:39 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <1211446045.5610.33.camel@elijah.suse.cz>
	 <3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	 <20080522111826.BB90326FA24@magilla.localdomain>
	 <3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
	 <20080522203428.835D626FA24@magilla.localdomain>
	 <3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
	 <20080523041940.39E8726FA24@magilla.localdomain>
	 <3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
	 <20080526001527.81E1126FA9E@magilla.localdomain>
In-Reply-To: <20080526001527.81E1126FA9E@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Mon, May 26, 2008 at 8:15 AM, Roland McGrath <roland@redhat.com> wrote:
>> "deliver" here I mean get_signal_to_deliver()...
>
> This can never happen inside ptrace_stop.
> So your line of inquiry doesn't make sense to me.

if happens, it should be a bug, right?

>
> Please tell us the exact code path you think is happening in the error case
> you can reproduce.
>
I will try to customize kernel to capture call trace for a precise code path.

--Luming
