From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 10 Nov 2003 10:33:31 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106846055028941@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi.

> Are you meaning 
> 
> synchronous MCA is caused within an execution context, for example
>     a process is doing a load and hits an exception
> 
> whereas a asynchronous MCA could happen when a line is written back
> to main memory and this could happen outside of the process's context ?

That's right.

Thus, the platform should use data poisoning to get capacity of sending
synchronous MCA instead of asynchronous MCA, even though the poisoning
is not the best way.


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

