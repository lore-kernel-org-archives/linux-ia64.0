From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 30 Jul 2008 14:08:47 +0000
Subject: Re: Anyone tested 2.6.27-rc1?
Message-Id: <20080730140847.GB31304@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080730063731.GA31304@parisc-linux.org>
In-Reply-To: <20080730063731.GA31304@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 30, 2008 at 06:42:38PM +1000, Peter Chubb wrote:
> Matthew> ... and that's it.  I'm trying to do something else, so I'll
> Matthew> probably just revert back to 2.6.26.
> 
> I get the same on a zx2000 with 2.6.26  plus a few patches ... I was
> planning to debug it today, only the disk in my zx2000 died, and I
> need to get that fixed first.

Just to confirm ... 2.6.26 with the zx1_defconfig boots fine ... so it's
something in the 8111 2.6.27 commits that breaks it.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
