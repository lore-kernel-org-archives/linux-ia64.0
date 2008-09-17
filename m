From: Roland McGrath <roland@redhat.com>
Date: Wed, 17 Sep 2008 17:12:10 +0000
Subject: Re: [patch 1/4] syscall.h support for ia64
Message-Id: <20080917171210.D22DA640A5@pipsqueak.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080917082022.087263904@sli10-desk.sh.intel.com>
In-Reply-To: <20080917082022.087263904@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is it really right not to handle the IS_IA32_PROCESS cases at all?
It looked me like it would be easy to handle those.

syscall_get_nr needs to return -1L when the task is not in a syscall.

This line concerns me:

+		count = min_t(int, args->n, cfm & 0x7f);

I take this to mean that you can tell how many arguments might be
accessible.  If fewer than 6 are available, you leave args[count..5]
uninitialized.  You should set them to something (e.g. 0 or -1),
or else this is an information leak of random kernel stack words.


Thanks,
Roland
