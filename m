From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 05 Jan 2005 11:35:44 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20050105113544.GC31285@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 21, 2004 at 06:20:08AM -0600, Dean Nelson wrote:
> I'm not sure that adding the 'flag' field is simpler than keeping things
> the way they are with the per-channel semaphores.

Well, keep them for now.

