From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 12 Feb 2008 04:29:38 +0000
Subject: Re: [PATCH 6/6] arch_ptrace() cleanup
Message-Id: <20080212042937.GA31794@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1202766249.9594.32.camel@elijah.suse.cz>
In-Reply-To: <1202766249.9594.32.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All these patches looks really great to me from the ptrace perspective.

While you're at cleaning up arch_ptrace it might be worth to convert
this odd indentation

>  	switch (request) {
>  	      case PTRACE_PEEKTEXT:
>  	      case PTRACE_PEEKDATA:

into the normal

	switch (request) {
	case PTRACE_PEEKTEXT:
	case PTRACE_PEEKDATA:

