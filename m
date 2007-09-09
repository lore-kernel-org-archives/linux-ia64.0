From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 09 Sep 2007 13:01:39 +0000
Subject: Re: [patch 4/5] Use extended crashkernel command line on IA64
Message-Id: <20070909130139.GF6809@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070909083914.065380136@strauss.suse.de> <20070909083915.165288618@strauss.suse.de>
In-Reply-To: <20070909083915.165288618@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org

On Sun, Sep 09, 2007 at 10:39:18AM +0200, Bernhard Walle wrote:
> Because the total amount of System RAM must be known when calling this
> function, efi_memmap_init() is modified to return its comulated 

accumulated?

> total_memory variable in a pointer value. IMO that's better than making the
> variable global.

Why not make efi_memmap_init() return total_memory instead of void?

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
