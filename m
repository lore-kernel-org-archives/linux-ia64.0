From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 20 Feb 2004 11:00:45 +0000
Subject: Re: [PATCH] MCA recovery from memory read error caused by application
Message-Id: <0HTD007P5QLAVE@fjmail501.fjmail.jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <0HTB004BEV6M3H@fjmail506.fjmail.jp.fujitsu.com>
In-Reply-To: <0HTB004BEV6M3H@fjmail506.fjmail.jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony-san,

Thank you for your reply.

> 1) Looking at gr13 in the minstate area when you determined that the
> MCA occurred in usermode will get you whatever value that the user
> happened to have in r13 ... not the task structure.

I couldn't notice it. I'll implement some value check.

> 2) Using "force_sig" in MCA context is probably going to violate some
> locking rules.  I'm making this blanket statement without looking at
> any code ... so I might be wrong ... but doing just about anything
> in an MCA handler runs into locking problems :-( .

Umm... Are there any better way?

> 3) You need some code to clean the error from the page.
> Otherwise the page will be freed when the process terminates,
> and the next user will possibly hit the same error.
> 
> Now some general philosophical issues:
> 
> This implemention is making the assumption that errors are
> soft ... i.e. that there is no permanent problem with the
> memory when an error is reported.  More often than not this
> assumption is true ... transient errors are more frequent
> than hard failures.  But many RAS people prefer to err on
> the side of paranoia, and might prefer to take the page with
> the error out of service.

Agree. The first thing to do is an isolation, and recycling is the next.


Thanks,

H.Seto

