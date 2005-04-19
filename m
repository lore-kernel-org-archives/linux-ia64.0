From: Andi Kleen <ak@suse.de>
Date: Tue, 19 Apr 2005 13:08:40 +0000
Subject: Re: [PATCH 2.4/2.6] arch/{ia64,x86_64,s390}: Fix: sys32_sendfile does not set offset on 32bit compat
Message-Id: <20050419130840.GC7715@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 19, 2005 at 11:13:47AM +0900, Yoshioka Tsuneo wrote:
> Hello
> 
> If we use 64bit kernel on ia64/x86_64/s390 architecture, and we run
> 32bit binary on 32bit compatibility mode, sendfile system call seems be
> not set offset argument.
> This is because sendfile's return value is not zero but the code regards
> the result by return value is zero or not.
> This problem will be affect to ia64/x86_64/s390 and not affect to other
> architecture does not affect other architecture (mips/parisc/ppc64/sparc64).
> So, I have multi-posted this e-mail to ia64/x86_64/s390 maintainer and
> mailling list.
> 
> Following patch will fix the problem. (I have confirmed on my EM64T
> machine.)

Thanks, looks good. Just need to figure out which of the architecture
maintainers pushes the patch now ,-)

-Andi
