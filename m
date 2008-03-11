From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 11 Mar 2008 14:07:20 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47D69218.2030801@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> ...
>>As far as the my MCA stuff is concerned, can you agree that it is
>>safer than the original code?
> 
> Yes.  I like your approach.  I want to make sure it works
> on larger systems.

If it comes from a boot command line option...

>>E.g. my MCA stuff can start up with, say, 3 buffers by default,
>>and you will be able to override it by a boot command line option.
> 
> How about having N be the number of actual cpus?  

Let me ask again: do you expect _independent_ MCAs to happen?
If you have got a estimation of the probability of independent
MCAs happening at a same time, different from what I calculated,
then please share it with us.

If the MCAs are the consequences of the same error event, then
you can find out what they are, where they are from 2 or 3 logs.

The code actual tries to recover local MCAs only. They are:
- TLB errors: per CPU local. As the CPUs are much more reliable
  then the other components, e.g. the memory, having two or
  more CPUs with corrupted TLBs at the same time is really unlikely.
- I/O or memory read errors:
  + One error has affected N CPUs: the first log is enough.
  + More than one independent error at the same time: assuming
    my estimations are more or less correct...

I still don't see any need for many buffers.

Thanks,

Zoltan
