From: Matthew Wilcox <matthew@wil.cx>
Date: Sat, 17 May 2008 07:30:33 +0000
Subject: Re: Locking API testsuite problem - Microblaze
Message-Id: <20080517073032.GA2638@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <482E8438.2040201@seznam.cz>
In-Reply-To: <482E8438.2040201@seznam.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Simek <monstr@seznam.cz>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, rth@twiddle.net, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Sat, May 17, 2008 at 09:07:36AM +0200, Michal Simek wrote:
> Hi Richard, Tony, Arnd and others,
> 
> I turn on API testsuite for Microblaze CPU for stable 2.6.24 and I got nice log
> with some faults. The same problem I have on latest version.
> 
> I found the similar problem for alpha CPU and ia64 but I haven't found solving
> these issues. Could you give me a hint how to solve this problem.

You missed the crucial line:

143 out of 218 testcases failed, as expected.

Some of these testcases are /expected/ to fail.  Succeeding would be an
bug.  There are no bugs here.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
