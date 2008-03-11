From: Robin Holt <holt@sgi.com>
Date: Tue, 11 Mar 2008 14:32:47 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <20080311143247.GD2013@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 11, 2008 at 03:07:20PM +0100, Zoltan Menyhart wrote:
> Let me ask again: do you expect _independent_ MCAs to happen?
> If you have got a estimation of the probability of independent
> MCAs happening at a same time, different from what I calculated,
> then please share it with us.
>
> If the MCAs are the consequences of the same error event, then
> you can find out what they are, where they are from 2 or 3 logs.
>
> The code actual tries to recover local MCAs only. They are:
> - TLB errors: per CPU local. As the CPUs are much more reliable
>  then the other components, e.g. the memory, having two or
>  more CPUs with corrupted TLBs at the same time is really unlikely.
> - I/O or memory read errors:
>  + One error has affected N CPUs: the first log is enough.
>  + More than one independent error at the same time: assuming
>    my estimations are more or less correct...

I don't know enough in this area to be of much use, but I do recall
times where a customer machine has run into an error and the neither the
first nor last record was of any use, but one of the intermediate
records.  I recall taking nearly a day to find the critical difference
and I vaguely recall it was on the order of 120 records and the useful
record was in the early 80s.  Russ certainly has more experience in this
area.

Thanks,
Robin
