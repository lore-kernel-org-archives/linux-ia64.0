From: Erich Focht <focht@ess.nec.de>
Date: Wed, 16 Jan 2002 21:04:53 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805862@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Jan 2002, Nick Pollitt wrote:

> With this patch I can boot UP, log in, etc.  I get did one compile 
> error in arch/ia64/kernel/setup.c, saying that the structure 'c' didn't
> have a member named 'processor' - sure looks like it does to me.
> 
> Did this patch work for you in the UP case?  If not I suspect our 
> hardware may be slightly different.  I'll attach my config just in case. 
> I'll try SMP tomorrow - getting late here.
> 
> Nick

I also needed an additional #ifdef CONFIG_SMP in setup.c around the line
which assigns c->processor = cpu(). So I guess our hardware is similar.
Can you reproduce the hang on the simulator?

Erich



