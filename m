From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 04 Apr 2005 13:45:35 +0000
Subject: Re: [PATCH] ULI 2.6.12
Message-Id: <20050404134535.GA9920@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050401130602.A123752@goliath.americas.sgi.com>
In-Reply-To: <20050401130602.A123752@goliath.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 04, 2005 at 08:31:44AM -0500, Michael Raymond wrote:
>     Again the idea is that the handler function was registered by root or
> some priviledged developer making a conscious decision.  This is currently
> protected by permissions on the /dev/uli file.  If you'd like me to add
> permission checks to the kernel functions I'd be happy to do it.

No, that's not the point.  User level interrupts are totally pointless if
they can cause the same problems on misbehaviour.

