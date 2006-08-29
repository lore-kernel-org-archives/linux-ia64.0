From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 29 Aug 2006 19:55:28 +0000
Subject: Re: Move perfmon tables from thread_struct to pfm_context
Message-Id: <20060829195528.GA17616@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829110856.A23515@unix-os.sc.intel.com>
In-Reply-To: <20060829110856.A23515@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 29, 2006 at 11:08:56AM -0700, Keshavamurthy Anil S wrote:
> This patch renders thread_struct->pmcs[] and thread_struct->pmds[]
> OBSOLETE. The actual table is moved to pfm_context structure which 
> is the right thing to do. Also this will in future avoid KABI breakages
> for the distro as well when the table size changes.

NACK.  There is no such thing as a KABI, and any patch the claims to
help towards it will automatically be rejected.  You should get a doctor
to help you stop seeing things like that.

