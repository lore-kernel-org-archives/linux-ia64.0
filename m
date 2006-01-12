From: Keith Owens <kaos@sgi.com>
Date: Thu, 12 Jan 2006 00:14:26 +0000
Subject: Re: [patch] implement ia64 specific mutex primitives
Message-Id: <20865.1137024866@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601112324.k0BNOog01764@unix-os.sc.intel.com>
In-Reply-To: <200601112324.k0BNOog01764@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Chen, Kenneth W" (on Wed, 11 Jan 2006 15:24:50 -0800) wrote:
>Implement ia64 optimized mutex primitives.  It properly uses 
>acquire/release memory ordering semantics in lock/unlock path.
>#define __mutex_fastpath_lock(count, fail_fn)				\
>static inline int
>__mutex_fastpath_lock_retval(atomic_t *count, int (*fail_fn)(atomic_t *))
>#define __mutex_fastpath_unlock(count, fail_fn)				\
>static inline int
>__mutex_fastpath_trylock(atomic_t *count, int (*fail_fn)(atomic_t *))

Instead of mixing #define and static, make them all static and let gcc
decide if you should inline them.  Or make them all #define.  Either
works but is more consistent.

