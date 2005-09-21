From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 21 Sep 2005 18:12:58 +0000
Subject: Re: MCA/INIT: need to wire CURRENT_STACK?
Message-Id: <ed5aea4305092111125edcf7d4@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16451.1127265127@ocs3.ocs.com.au>
In-Reply-To: <16451.1127265127@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> BUT ... it raises the question of whether you will do anything
> in your MCA handler that will run into problems because the stack
> is perhaps[1] not pinned ... just mapped by a DTC entry.  I forget
> what the exact issue is that led to pinning the stack with DTR[2],
> but there is a correctness issue involved.  David: memory jog time??

Any virtually mapped memory that needs to be accessed with PSR.IC=0
needs to be pinned because otherwise you'd get a nested TLB fault and
things would go south from there real fast.

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
