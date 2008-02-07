From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 07 Feb 2008 08:49:16 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <20080207084916.GA21720@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 06, 2008 at 09:37:54AM -0800, Luck, Tony wrote:
> > Any reason the various ptrace bits are not included in this pull?
> 
> The ptrace bits depend upon some generic changes to add arch_ptrace_stop()
> ... I think Andrew included them as part 89/260 of today's early
> morning mail patch bomb.

Yes, arch_ptrace_stop is in now.
