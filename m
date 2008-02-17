From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 17 Feb 2008 14:08:21 +0000
Subject: Re: git-nfsd on ia64
Message-Id: <20080217140821.GA21012@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
In-Reply-To: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Feb 17, 2008 at 08:21:32AM -0500, Christoph Hellwig wrote:
> That implies maintainers actually maintaining it.  When did we get the
> last real update (nto just removeing dead options) to the 32bit x86
> defconfig?

The last one I recall was in July 2006 when someone set the SUSPEND
partition in defconfig and machines without that partition existing
would panic on bootup.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
