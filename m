From: David Miller <davem@davemloft.net>
Date: Wed, 19 Aug 2020 20:02:22 +0000
Subject: Re: [PATCH v2 06/11] sparc: switch to kernel_clone()
Message-Id: <20200819.130222.1915954815957844234.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819104655.436656-1-christian.brauner@ubuntu.com>
        <20200819104655.436656-7-christian.brauner@ubuntu.com>
In-Reply-To: <20200819104655.436656-7-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: christian.brauner@ubuntu.com
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, corbet@lwn.net, ysato@users.sourceforge.jp, tony.luck@intel.com, fenghua.yu@intel.com, geert@linux-m68k.org, ley.foon.tan@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, arnd@arndb.de, rostedt@goodmis.org, shorne@gmail.com, peterz@infradead.org, jongk@linux-m68k.org, keescook@chromium.org, green.hu@gmail.com, ebiederm@xmission.com, mchehab+huawei@kernel.org, alexandre.chartre@oracle.com, mhiramat@kernel.org, zanussi@kernel.org, yangx.jy@cn.fujitsu.com, linux-doc@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-kselftest@vger.kernel.org, torvalds@linux-foundation.org, hch@infradead.org, willy@infradead.org

From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Wed, 19 Aug 2020 12:46:50 +0200

> The old _do_fork() helper is removed in favor of the new kernel_clone() helper.
> The latter adheres to naming conventions for kernel internal syscall helpers.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: sparclinux@vger.kernel.org
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>

Acked-by: David S. Miller <davem@davemloft.net>
