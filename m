From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 13 Mar 2002 20:33:25 +0000
Subject: Re: [Linux-ia64] qla1280 driver update
Message-Id: <marc-linux-ia64-105590701905263@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905261@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905261@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jesse" = Jesse Barnes <jbarnes@sgi.com> writes:

Jesse> You wouldn't happen to know where I could find a patch like this
Jesse> for qlogicfc.c, would you?  It doesn't look like it works in
Jesse> 2.5.5 either...

Not for qlogicfc.c, I think that driver is pretty much considered
obsolete. However I know Arjan is working on something for the qla2x00
driver written by QLogic which is just as messy as the 1280 used to
be. I think you can find Arjan's patches in the Red Hat RawHide SRPMS.

Cheers,
Jes

