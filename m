From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 25 Jul 2007 15:26:42 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <1185377202.16367.8.camel@phobos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2007-07-25 at 22:37 +0900, Horms wrote:

> I was also seeing a strange problem relating to the
> vector domain patch which seemed to be causing
> corruption of vectors_in_migration, which caused migrate_irqs()
> to emmit suprious IRQ errors (when called by kexec).
> 
> I'll try and confirm that this patch soles the problem that
> I was seeing tomorrow.
> 

You may also want to try this patch:
http://www.mail-archive.com/linux-ia64@vger.kernel.org/msg03113.html

- Doug


