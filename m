From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 09 Feb 2008 05:04:37 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <20080209050437.GD1428@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 08, 2008 at 02:46:25PM -0800, Luck, Tony wrote:
> Petr Tesarik (3):
>       [IA64] Rename TIF_PERFMON_WORK back to TIF_NOTIFY_RESUME
>       [IA64] Synchronize kernel RSE to user-space and back
>       [IA64] Synchronize RBS on PTRACE_ATTACH

This is still not killing the now unessecary find_thread_for_addr gunk
and the conversion to arch_ptrace.    Any reason that got delayed again?
Currently ia64 is one out of two architectures left still having it's
own sys_ptrace.
