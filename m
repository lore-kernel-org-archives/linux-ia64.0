From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 05 Dec 2005 22:21:10 +0000
Subject: Re: Reading /proc/stat is slooow
Message-Id: <20051205222110.GA1034@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 02, 2005 at 06:42:49PM +0100, Andreas Schwab wrote:
> At some point after 2.6.13 reading /proc/stat has become too slow.  This
> is most visible with xosview, which spends up to 80% in kernel space.  I
> have attached a simple program that you can run with "strace -r" to see
> that the second read of /proc/stat which eventually returns EOF takes too
> much time.  If you remove the loop around read the same amount of time is
> now spent in close.


How slow is sloow?  Or did this get fixed already?  Here's some
strace -r output from 2.6.15-rc5 (on 2cpu HP rx2620, 1.3GHz):

     0.000163 open("/proc/stat", O_RDONLY) = 3
     0.000166 read(3, "cpu  1695 1 5317 1124699 4124 6 "..., 8192) = 723
     0.000221 read(3, "", 8192)         = 0
     0.000135 close(3)                  = 0
     0.000141 nanosleep({0, 300000000}, NULL) = 0
     0.303585 open("/proc/stat", O_RDONLY) = 3
     0.000135 read(3, "cpu  1695 1 5317 1124851 4124 6 "..., 8192) = 723
     0.000214 read(3, "", 8192)         = 0
     0.000132 close(3)                  = 0
     0.000130 nanosleep({0, 300000000}, NULL) = 0

So yes, the read that returns the EOF takes way longer than the read
that returns the actual data, but is that the amount of sloowness that
you see?  The whole "open, read, read, close" sequence is < 1ms.

-Tony
