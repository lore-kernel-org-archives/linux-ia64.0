From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 24 Aug 2003 15:02:45 +0000
Subject: Re: selinux build failure
Message-Id: <marc-linux-ia64-106173738323797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106161286205885@msgid-missing>
In-Reply-To: <marc-linux-ia64-106161286205885@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 25, 2003 at 12:49:52AM +1000, James Morris wrote:
> > see a good way to #include asm/compat.h, nor is it available for all
> > processor architectures.
> 
> It is available via <linux/compat.h> if CONFIG_COMPAT is defined.
> 
> Does the patch below fix this for you?

Argg, this is b0rked.  {asm,linux}/compat.h are for the 32bit compatiblity
code.  64bit arches don't have fcntl64 - see the #if BITS_PER_LONG = 32
around sys_fcntl64 in fcntl.c..

