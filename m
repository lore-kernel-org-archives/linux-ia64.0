From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Sat, 26 Oct 2002 01:09:28 +0000
Subject: Re: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805256@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I succeeded to boot the kernel on 8way ia64 box by
porting the generic percpu (i.e. i386's percpu) to ia64.
I think this should not right way to fix the problem.
I can show the patch if there is a requirement.

Thanks,
Kimi

On Fri, 25 Oct 2002 16:23:43 -0700
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> wrote:

> I found that functions in timer.c and rcupdate.c are calling
> tasklet_init() for all CPUs before APs start running.
> I think per_cpu() cannot be used for not running CPU for ia64,
> and this assumption was broken by them.
> 
> I attached args for tasklet_init() at booting and you can see
> tasklet structures for CPU#0 are only valid.
> Caller might be init_timers() and rcu_init().
> 
> I cannot come up with good solution for it but I think
> we have to change current per_cpu implementation.
> Any idea?

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


