From: john stultz <johnstul@us.ibm.com>
Date: Tue, 18 Nov 2003 18:44:03 +0000
Subject: Re: [RFC][PATCH] linux-2.4.23-pre9_ia64-cyclone_A0
Message-Id: <marc-linux-ia64-106918249303475@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106911773604958@msgid-missing>
In-Reply-To: <marc-linux-ia64-106911773604958@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2003-11-18 at 08:42, Bjorn Helgaas wrote:
> Apart from that correctness question, I have some concerns about
> how the code is structured.  I don't think I've seen the actual
> SGI patch either, but based on John Hawkes' email (URL above),
> the hook looks something like:
> 
> +               if (ia64_platform_timer_interrupt)
> +                       (*ia64_platform_timer_interrupt)();
> 
> That's far better than adding stuff like this:
> 
> +       if(use_cyclone)
> +               return do_gettimeoffset_cyclone() + lost * (1000000 / HZ);
> 
> because the former is much more generic.

Very much agreed. 

> I also don't like adding asm-ia64/cyclone.c and ia64/kernel/cyclone.c.
> Those files are machine-specific and don't belong in the generic ia64
> area.  (In fact, they look functionally identical to the i386 code;
> could this all be consolidated in something under drivers/ and shared?)

My plan is to do exactly that (and a bit more) for 2.7. As for 2.4 and
2.5, I'm a bit more hesitant about consolidating the code across arches.
Outside the constants and init function not much is really shared
(although they are structurally similar), and there are still some
subtle differences between those (casting changes and fixmap vs
ioremap). At this point I'd like to avoid the code churn in the i386
dir. However I'd be happy to more the ia64 bits into drivers/ as you
suggest. 

thanks for the feedback!
-john


