From: Matthew Wilcox <willy@debian.org>
Date: Mon, 22 Mar 2004 12:15:44 +0000
Subject: Re: testing a new syscall
Message-Id: <20040322121544.GB25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040322021555.7b6f9317.akpm@osdl.org>
In-Reply-To: <20040322021555.7b6f9317.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 22, 2004 at 02:15:55AM -0800, Andrew Morton wrote:
> I'm trying to work out how to test the new remap_file_pages() syscall on
> ia64 and have conceded defeat.
> 
> I got this far, but it segfaults:
> 
> #elif __ia64__
> #define __NR_sys_remap_file_pages 1259
> ...
> _syscall5(long, sys_remap_file_pages, unsigned long, start, unsigned long, len,
>         unsigned long, prot, unsigned long, pgoff, int, flags);
> 
> ....
> 
> #if defined(__ia64__)
> 
> asm(
> "	.text\n"

Argh!  Assembler!  Run away ;-)

Here's the better way to do it (cribbed from manfred's mqueue work):

static inline long remap_file_pages(unsigned long start, unsigned long len,
		unsigned long prot, unsigned long pgoff, int flags)
{
	return syscall(__NR_sys_remap_file_pages, start, len, prot, pgoff,
			flags);
}

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
