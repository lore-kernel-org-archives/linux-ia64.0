From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sat, 04 Aug 2018 21:33:36 +0000
Subject: Re: [PATCH v2, simpler] ia64: fix ptrace(PTRACE_GETREGS) (unbreaks strace, gdb)
Message-Id: <20180804223336.5f29778e@sf>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180211185134.76ccfd45@sf>
        <20180309231555.16925-1-slyfox@gentoo.org>
In-Reply-To: <20180309231555.16925-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri,  9 Mar 2018 23:15:55 +0000
Sergei Trofimovich <slyfox@gentoo.org> wrote:

I tried to explain in more detail breakage mechanics
of unwinder and gcc code generation quirks at:
    https://trofi.github.io/posts/210-ptrace-and-accidental-boot-fix-on-ia64.html
Hopefully it gives better intuition of code change
caused by both proposed patches.

I personally think v1 patch is slightly more robust.

-- 

  Sergei
