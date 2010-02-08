From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 08 Feb 2010 19:24:30 +0000
Subject: Re: binfmt_elf32 / compat_binfmt_elf.c
Message-Id: <20100208192430.GA30349@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100205153253.GA24644@infradead.org>
In-Reply-To: <20100205153253.GA24644@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 08, 2010 at 11:21:33AM -0800, Luck, Tony wrote:
> > It looks like IA64 still has it's own binfmt_elf32.c instead of using
> > the generic fs/compat_binfmt_elf.c which is used by other architectures
> > that have the regset infrastucture.  Any good reason for skipping that
> > part of the conversion?
> 
> What if I just remove it, along with the rest of CONFIG_IA32 support?
> Nobody uses this code any more.

That would make life even easier..

