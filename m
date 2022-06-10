From: kernel test robot <lkp@intel.com>
Date: Fri, 10 Jun 2022 21:02:21 +0000
Subject: Re: [PATCH 1/2] Add CABA tree to task_struct
Message-Id: <202206110409.b8UJYnuq-lkp@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610163214.49974-2-ptikhomirov@virtuozzo.com>
In-Reply-To: <20220610163214.49974-2-ptikhomirov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, linux-kernel@vger.kernel.org
Cc: kbuild-all@lists.01.org, Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, Eric Biederman <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, Valentin Schneider <vschneid@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-ia64@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi Pavel,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on shuah-kselftest/next]
[also build test WARNING on kees/for-next/execve tip/sched/core linus/master v5.19-rc1 next-20220610]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/intel-lab-lkp/linux/commits/Pavel-Tikhomirov/Introduce-CABA-helper-process-tree/20220611-003433
base:   https://git.kernel.org/pub/scm/linux/kernel/git/shuah/linux-kselftest.git next
config: i386-randconfig-a001 (https://download.01.org/0day-ci/archive/20220611/202206110409.b8UJYnuq-lkp@intel.com/config)
compiler: gcc-11 (Debian 11.3.0-3) 11.3.0
reproduce (this is a W=1 build):
        # https://github.com/intel-lab-lkp/linux/commit/0875a2bed5ff95643c487dfcc28a550db06ea418
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Pavel-Tikhomirov/Introduce-CABA-helper-process-tree/20220611-003433
        git checkout 0875a2bed5ff95643c487dfcc28a550db06ea418
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        make W=1 O=build_dir ARCH=i386 SHELL=/bin/bash fs/proc/

If you fix the issue, kindly add following tag where applicable
Reported-by: kernel test robot <lkp@intel.com>

All warnings (new ones prefixed by >>):

   fs/proc/array.c: In function 'task_state':
>> fs/proc/array.c:157:15: warning: unused variable 'caba_pids' [-Wunused-variable]
     157 |         pid_t caba_pids[MAX_PID_NS_LEVEL] = {};
         |               ^~~~~~~~~
>> fs/proc/array.c:156:13: warning: unused variable 'caba_level' [-Wunused-variable]
     156 |         int caba_level = 0;
         |             ^~~~~~~~~~
>> fs/proc/array.c:155:21: warning: unused variable 'caba_pid' [-Wunused-variable]
     155 |         struct pid *caba_pid;
         |                     ^~~~~~~~
>> fs/proc/array.c:154:29: warning: unused variable 'caba' [-Wunused-variable]
     154 |         struct task_struct *caba;
         |                             ^~~~


vim +/caba_pids +157 fs/proc/array.c

   143	
   144	static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
   145					struct pid *pid, struct task_struct *p)
   146	{
   147		struct user_namespace *user_ns = seq_user_ns(m);
   148		struct group_info *group_info;
   149		int g, umask = -1;
   150		struct task_struct *tracer;
   151		const struct cred *cred;
   152		pid_t ppid, tpid = 0, tgid, ngid;
   153		unsigned int max_fds = 0;
 > 154		struct task_struct *caba;
 > 155		struct pid *caba_pid;
 > 156		int caba_level = 0;
 > 157		pid_t caba_pids[MAX_PID_NS_LEVEL] = {};
   158	
   159		rcu_read_lock();
   160		ppid = pid_alive(p) ?
   161			task_tgid_nr_ns(rcu_dereference(p->real_parent), ns) : 0;
   162	

-- 
0-DAY CI Kernel Test Service
https://01.org/lkp
