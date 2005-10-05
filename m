From: Jeff Licquia <licquia@progeny.com>
Date: Wed, 05 Oct 2005 22:13:05 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <1128550385.4623.52.camel@laptop1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-10-05 at 14:54 -0700, Luck, Tony wrote:
> >It was suggested to me that this might be of interest outside the LSB,
> >and that I should forward it more widely...
> 
> Running under strace, I see you write 2048 bytes at a time until you
> see EAGAIN.  Then you read 4096 bytes to empty the pipe a little.
> 
> Then you try to write 4120 bytes (more than you just emptied).
> 
> Is that what you are trying to do?

That sounds about right.

FWIW, if you'd like a look at the source of one of the LSB tests that's
failing, see:

http://cvs.gforge.freestandards.org/cgi-bin/cvsweb.cgi/tests/lsb-runtime-test/modules/vsx-pcts/tset/ANSI.os/streamio/fwrite/fwrite.c?rev=1.1.1.1&contenttype=text/x-cvsweb-markup&cvsroot=lsb

Look at function "test3", specifically the part after where it reports
"testing assertion using non-blocking pipe".

> Do you expect a partial write, rather than the EAGAIN?

That appears to be what's happening in most other cases, and also
appears to be what the LSB tests want.

