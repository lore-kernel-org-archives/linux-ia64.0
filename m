From: Matthew Wilcox <willy@debian.org>
Date: Tue, 18 Nov 2003 12:59:54 +0000
Subject: Re: problem in booting HP zx6000 with stock kernel 2.4.18
Message-Id: <marc-linux-ia64-106916058707194@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 18, 2003 at 11:57:29AM +0530, Deepak Kumar Gupta, Noida wrote:
> Hello everybody
> 
> I am trying to boot 2 CPU hp zx6000 machine (ia64, itanium2) from STOCK
> kernel version 2.4.18. I have followed following steps.

Why 2.4.18?  Could you try something more recent like 2.4.22?  2.4.18
is rather old (25-Feb-2002) and it doesn't seem reasonable to try to
track down this bug (I vaguely remember it ...) in such an old kernel.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
