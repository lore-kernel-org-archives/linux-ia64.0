From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 19 Sep 2003 18:11:56 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399512918536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 11:47:46AM -0600, Bjorn Helgaas wrote:
> It looks like at least the ql2xxx stuff is (a) not in the 2.5
> tree, and (b) not in Red Hat kernels.
> 
> So who cares about this stuff?  If I dropped it out of the
> ia64 patch, would anybody be upset enough to help sort
> this out?

The qla2x00 in your tree is utter crap, so please drop it.
For qla1280 I still hope Jes pushes his latest to Marcelo..

