From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 07 Nov 2003 09:51:50 +0000
Subject: Re: [PATCH] salinfo for 2.6.0-test9
Message-Id: <marc-linux-ia64-106824271216461@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106812011912671@msgid-missing>
In-Reply-To: <marc-linux-ia64-106812011912671@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> salinfo has been completely redone in 2.4.23-pre9, the 2.4.22 version
> of salinfo had races and deadlocks for all record types, it was not
> safe for MCA/INIT processing and could break the MCA/INIT code in
> mca.c.  Please do not update salinfo in 2.6 until Bjorn gets back and
> we work out the last few patches to salinfo in 2.4.

That was one that I had made for test, but I don't know it have such problems.
OK. I just wait for coming 2.4.23 and 2.6.0, and for looking Bjorn's new
patch.

Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>



