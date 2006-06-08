From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 08 Jun 2006 17:48:33 +0000
Subject: Re: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <20060608174833.GH1651@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 08, 2006 at 10:51:13PM +0530, vamsi krishna wrote:
> Hell Andreas,
> >You also need to make sure that all function descriptors end up at the
> >very same address.
> 
> Do you mean file descriptors?

No.  A function descriptor is sometimes called a 'fat pointer'.
Function pointers on ia64 (as with ppc64 and parisc) are not pointers to
the start of the function.  Instead they are pointers to function
descriptors -- small structs which contain information about the
function, including a pointer to the start of the function.

http://lists.debian.org/debian-ia64/2003/10/msg00056.html may be of
interest.
