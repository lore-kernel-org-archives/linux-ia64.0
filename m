From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 20 Sep 2003 07:20:25 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106404244824429@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 11:40:29AM -0700, Grant Grundler wrote:
> I'd think Jes could(had?) submit(ted) qla1280 bits himself upstream.

Last time I asked him (ok, that's a looong time ago) he didn't want to
submit it for 2.4.  His driver is in 2.5 though but is 2.4-compatible.

It would be really nice (TM) to see it in Marcelo's tree.

> I thought for 2.5.x someone was maintaining an 8.x qla FC driver which was
> in parallel with qla2xxx 6.x FC drivers maintained by qlogic.
> I'm not sure what happened here since I don't see it in
> David's linux-ia64-2.5 bk tree.

Well, that someone is qlogic.  But I don's see why it should go into
the ia64 tree.  Once qlogic got the driver in shape it and/or the feral
driver should go into mainline.  This is actually on the 2.6 should-fix
list.

