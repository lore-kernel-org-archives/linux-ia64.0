From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 21 Oct 2009 06:43:31 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.DEB.1.10.0910210236360.9745@gentwo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <20091020061557.GE8550@elte.hu> <alpine.LSU.2.00.0910200820500.8582@wotan.suse.de> <20091020063555.GJ8550@elte.hu>
 <4ADDB640.4020707@suse.com> <20091020134308.GA3930@elte.hu> <4ADDC1C6.9090305@kernel.org> <4ADDC1FC.8010903@kernel.org>
In-Reply-To: <4ADDC1FC.8010903@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Mahoney <jeffm@suse.com>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, peterc@gelato.unsw.edu.au

The suggestion to Tony was to stop using the fixed TLB address for the per
cpu areas and instead use a global register like on x86 and sparc. Peter
Chubb then said that we had available global registers (cced him) that
could be used for this purpose. Doing so would make percpu support conform
to the schemes used by other architectures.

However, IA64 supports TLBs for larger pages (128MB, 256MB ...). So we
could change the maximum size of the static percpu data by using a
different sized TLB entry.

Tony?
