From: Joshua Aas <josha@sgi.com>
Date: Thu, 15 Jul 2004 14:57:27 +0000
Subject: Re: print CPU number when warning of hazards
Message-Id: <40F69B57.6030804@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F5AAA8.5020500@sgi.com>
In-Reply-To: <40F5AAA8.5020500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>>>>>>On Wed, 14 Jul 2004 16:50:32 -0500, Joshua Aas <josha@sgi.com> said:
> 
> 
>   Joshua> Hello, The following patch would be useful for diagnostics.
> 
> Why does the CPU help there?  Depenency-violations are specific to
> code, so why would the CPU matter?

The idea was that it would be useful for hardware debugging - if bad hardware tripped that code then one could see what CPU it was on. Adding the CPU number there would be trivial because a printk already exists. However, after further discussions I've decided to pursue another solution which I will probably post about later. Adding the CPU number where my patch did raises the argument of "then why not do that everywhere error conditions that could be hardward related come up?", which I don't want to do.

So, it wouldn't hurt to add the CPU number there but on my end I'm not all that interested in it any more.

> Apart from that, have you actually
> ever seen that message show up?

No - I was was operating on the assumption that our hardware diagnostics people do see it.

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068
