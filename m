From: Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>
Date: Wed, 15 Sep 2004 16:00:04 +0000
Subject: Re: INIT dumps broken?
Message-Id: <20040916.010004.846960466.miyoshi@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello, 

> Can anybody describe why cpu 0 changed from 0xe... to 0xa... for the
> idle task between 2.6.7-rc3 and 2.6.8?

init_task is initialized by INIT_TASK macro and it fills the init_task
with 0xa.. value, which is computed at compilation time. 
Thus, we observed 0xa.. link lists from 0xe.. mapping and it caused
panic with components which refer swapper.

Actually, there was different approach which is to initialize init_task
again with 0xe.. value after boot, but it requries future maintainance
of the re-initialization with the changes of task_struct.
That is the reason we proposed the patch to maintain coherent view of
task_struct.

Currently we do not have consistent way to solve the problem,
but we will try to think about fixing the problem.

BTW, I tried INIT on my box but it seemed to produce correct task
dump to the console. I will look at it more closely...

Best Regards,
--
Kazuto Miyoshi, NEC
miyoshi@hpc.bs1.fc.nec.co.jp


