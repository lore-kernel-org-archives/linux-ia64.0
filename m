From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 23 Sep 2003 19:22:31 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434575513158@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 03:11:28PM -0400, Benjamin LaHaise wrote:
> On Tue, Sep 23, 2003 at 03:10:11PM -0400, Jeff Garzik wrote:
> > Traditionally, if the NIC driver is accessing unaligned data, it should
> > be using get/put_unaligned().
> 
> The driver isn't, the networking stack is (it has to).  For more examples 
> where this behaviour is required: PPPoE, VLAN...

Oh, no argument....  agreed 100%

	Jeff



