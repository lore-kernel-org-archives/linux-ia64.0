From: Jeff Licquia <licquia@progeny.com>
Date: Wed, 05 Oct 2005 22:30:35 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <1128551435.4623.67.camel@laptop1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-10-05 at 15:09 -0700, Luck, Tony wrote:
> >Do you expect a partial write, rather than the EAGAIN?
> 
> I suppose you should expect EAGAIN here: http://tinyurl.com/82wr9
> describes this situation quite clearly.
> 
> So either:
> 1) ia64 thinks 4120 is less than PIPE_BUF, so that it believes
>    that it should not do a partial write

Except that the test code asks the system for PIPE_BUF, and then adds to
it to determine how much to write.  (See lines 26, 32, and 33 of my
test.)  Specifically, we try to write PIPE_BUF + 24 bytes.

> 2) Even though we removed some data from the pipe, it thinks that
>    it is still all the way full.

Hmm.  The spec doesn't seem to say whether a read of PIPE_BUF bytes on a
full pipe _must_ put the pipe in a state where it can accept more input.
The test, certainly, seems to think this is mandatory.

> [My tests on 2.6.14-rc2].
> 
> Which other architectures have you tried this on?  Is ia64 all alone
> in failing this test?

Yup.  In fact, only recent kernels fail; 2.6.8 succeeds, while 2.6.12
fails.

For other architectures, I've tested on i386 and amd64 for both 2.6.8
and 2.6.12 kernels.

