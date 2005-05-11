From: Francois Wellenreiter <Francois.Wellenreiter@bull.net>
Date: Wed, 11 May 2005 06:06:54 +0000
Subject: Re: KDB improvements for IA64
Message-Id: <4281A0FE.1030300@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4280D2C5.3060604@bull.net>
In-Reply-To: <4280D2C5.3060604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>>>>>>On Tue, 10 May 2005 17:27:01 +0200, Francois Wellenreiter <Francois.Wellenreiter@bull.net> said:
> 
> 
>   Francois> - timeouts when exiting from KDB will never occur I have
>   Francois> noticed that after a long time in KDB, some drivers enter
>   Francois> in timeout sequences. Now, the different ITC values are
>   Francois> saved when entering KDB and restored when going out.
> 
> This sounds fragile to me.  For one thing, the kernel may not use ITC
> at all for timeouts (true for most NUMA platforms).  Also, even if the
> ITC is in use, you'd probably have to resync them on the slave CPUs
> after restoring the time-keeper's ITC value.  Not to mention that if
> the timeout is related to an external event, then faking time won't
> help no matter what.
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


		David,

	I agree that ITC management may be a bit risky and overall is 
platform-dependent, but in my opinion, that was a better way than saving and
restoring global xtime variable which can be modified by only one CPU
(the main danger in such a case may occur when this CPU is working
when the other ones are already running KDB).

The time-outs that I have noticed dealt with journalled filesystem messages
(and sometimes lead to an unrecoverable machine crash),
that is the reason why I have implemented this feature. On the different
NUMA machines that I have tested, this problem did not appear again.

If you have some implementation ideas, they are really welcome.

Regards,

		Francois
