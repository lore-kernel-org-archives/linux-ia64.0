From: Christoph Hellwig <hch@lst.de>
Date: Tue, 26 Jun 2007 05:52:36 +0000
Subject: Re: [PATCH 2/3] Remove JPROBE_ENTRY()
Message-Id: <20070626055236.GA6841@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au> <98c8ff25191ced991066092ffd4899526097da1e.1182822366.git.michael@ellerman.id.au>
In-Reply-To: <98c8ff25191ced991066092ffd4899526097da1e.1182822366.git.michael@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <michael@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, anil.s.keshavamurthy@intel.com, ananth@in.ibm.com

On Tue, Jun 26, 2007 at 11:48:51AM +1000, Michael Ellerman wrote:
> AFAICT now that jprobe.entry is a void *, JPROBE_ENTRY doesn't do
> anything useful - so remove it ..
> 
> I've left a do-nothing version so that out-of-tree jprobes code will still
> compile without modifications.

Please kill the definition.  We don't want to keep unused crap around
just to let code compile.  And I have some plans for even deeper change
in this area, so they'll have to change anyway.

