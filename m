From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 04 Sep 2004 16:57:34 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040904175734.A16526@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 04, 2004 at 05:55:16PM +0100, Christoph Hellwig wrote:
> > hot and need to broken up.  So that is why you will find people that
> > believe that it is simpler and less complex to design in fine grain locks,
> > to avoid having to track down and fix scaling bugs.  
> 
> Have you not looked at the code or are you publically trying to make a fool
> of yourself?
> 
> The lock is taken during xfc_connect/disconnect which happen exactly at
> ifconfig up/down time.  Please explain me why ifconfig scalability matters
> to SGI.

And btw, as your trying to play mister smartass here:  if you removed
support for the second possible channel instead of keeping it as hook
for your propritary xpmem module we'd have only one lock anyway.  What
about just completely killing support for that second channel and we
don't need to dicuss this issue at all.

