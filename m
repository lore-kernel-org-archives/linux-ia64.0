From: Keith Owens <kaos@sgi.com>
Date: Sat, 22 Jan 2005 01:02:26 +0000
Subject: Re: optimize __gp location
Message-Id: <10878.1106355746@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 21 Jan 2005 15:22:18 -0800, 
"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>__gp is positioned so far out that it is almost at the end of all data
>sections.  On 2.6.11-rc1, 80% of kernel data symbols are out of 22-bit
>immediate offset from __gp.  This means accessing these symbols are 
>unnecessarily expansive such that they have to go through global offset
>table (a memory load to get the symbol address).  Among these out of
>reach symbols from __gp, some are very frequently used, like Jiffies,
>etc.
>
>Can we position the __gp somewhat more optimally, to cover more of these
>symbols? Something like the following patch would make all of them fall
>into the 22-bit immediate offset relative to gp.

The best place for __gp is in the exact middle of the range
.data.init_task through the end of .sbss.  Unfortunately a large .data
section could result in .got and .sbss being out of range of a median
__gp.  Is it possible in the linker script to first try (.sbss.end -
.data.init_task) / 2, then test the result for reachability to .sbss
and adjust __gp if necessary?

