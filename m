From: Matthew Wilcox <willy@debian.org>
Date: Wed, 14 Jul 2004 21:09:03 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the posix-timer functions to return higher
Message-Id: <20040714210903.GA32326@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Jul 14, 2004 at 09:41:03AM -0700, Christoph Lameter wrote:
> The following patch introduces a new gettimeofday function using
> struct timespec instead of struct timeval. If a platforms supports time
> interpolation then the new gettimeofday will use that to provide a
> gettimeofday function with higher accuracy and then also clock_gettime
> will return with nanosecond accuracy.

You seem to have included two patches here that are very similar ...
could you send the patch you intended please?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
