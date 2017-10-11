From: Dave Chinner <david@fromorbit.com>
Date: Wed, 11 Oct 2017 20:50:33 +0000
Subject: Re: [PATCH v6 00/11] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <20171011205033.GK15067@dastard>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
In-Reply-To: <1507744922-15196-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>

On Wed, Oct 11, 2017 at 02:01:51PM -0400, Waiman Long wrote:
> In term of rwsem performance, a rwsem microbenchmark and fio randrw
> test with a xfs filesystem on a ramdisk were used to verify the
> performance changes due to these patches. Both tests were run on a
> 2-socket, 40-core Gold 6148 system. The rwsem microbenchmark (1:1
> reader/writer ratio) has short critical section while the fio randrw
> test has long critical section (4k read/write).
> 
> The following table shows the performance of the rwsem microbenchmark
> and fio radrw test with different number of patches applied on 4.14
> based kernels:
> 
>   # of Patches	Locking Rate	FIO Bandwidth	FIO Bandwidth
>     Applied	 40 threads	 32 threads	 16 threads
>   ------------	------------	-------------	-------------
> 	0	  38.7 kop/s	  706 MB/s	  704 MB/s
> 	7	  38.6 kop/s	  668 MB/s	  663 MB/s
> 	8	  38.9 kop/s	  704 MB/s	  701 MB/s
> 	9	  39.1 kop/s	  702 MB/s	  707 MB/s
>        11	3218.0 kop/s	 2594 MB/s	 2614 MB/s
> 
> So this patchset improves mixed read/write rwsem microbench by 83X
> and randrw fio bandwidth by about 3.7X.

Overall improvement in bandwidth is not necessarily a good thing -
this could simply demonstrate total write bandwidth starvation and
so it's only reporting read bandwith. It's much more important to
look at the change in read bandwidth vs write bandwidth in the fio
test. i.e. exactly how did the IO balance change as a result of
changing the locking bias?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
