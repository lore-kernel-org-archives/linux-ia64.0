From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 08 Sep 2003 19:08:42 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106304868523395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 05, 2003 at 11:19:13AM +0200, Xavier Bru wrote:
> About code cleaning, it seems that the IA64_NODESIZE_* 
> options are still present in Kconfig but no more used, at least for
> DIG platforms.

I've removed these in the patch as well, I'll post a new one for testing
soon.

Thanks,
Jesse
