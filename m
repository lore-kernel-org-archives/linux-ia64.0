From: Martin Pool <mbp@samba.org>
Date: Fri, 24 Oct 2003 23:45:31 +0000
Subject: Re: anyone caring about ipchains?
Message-Id: <marc-linux-ia64-106703917024798@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106703690322657@msgid-missing>
In-Reply-To: <marc-linux-ia64-106703690322657@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 24 Oct 2003, David Mosberger <davidm@napali.hpl.hp.com> wrote:
> I noticed that ipchains isn't terribly stable in 2.6.0-test8.  For me,
> it caused a kernel hang after masquerading a client doing some web
> surfing.  Actually, it never was terribly good even on 2.4.21 as it
> would cause periodic stalls (not quite as bad as the 2.6 behavior, but
> still not great).  iptables on the other hand seems to work quite
> well.  Does anyone still care about ipchains or should we just declare
> it dead technology?

I had the idea from Rusty that since it has been deprecated for a
couple of years, it was OK for it to break unless somebody cared
enough to maintain it.  Maybe post to l-k to see?

--
Martin
