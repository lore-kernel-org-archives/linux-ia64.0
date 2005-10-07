From: Jeff Licquia <licquia@progeny.com>
Date: Fri, 07 Oct 2005 14:29:43 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <1128695383.21049.11.camel@server1.internal.licquia.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-10-05 at 16:28 -0700, Luck, Tony wrote:
> Now, the question becomes "is this a bug". As you pointed
> out in an earlier e-mail the standard makes no mention of
> what happens when you read some data from a full pipe. So
> we appear not to be in violation of the letter of the standard.
> 
> But this does fly in the face of common sense.
> 
> As you say above, reporting the PIPE_BUF value as PAGE_SIZE
> [probably max(4096, PAGE_SIZE) ... for any arch that has a
> page size smaller than 4k] would fix this.  But then we get
> back to the historical properties of 4k as the PIPE_BUF size.
> Would such a change break existing applications that are not
> well enough written to use fpathconf(fd, _PC_PIPE_BUF)?

I think there's a problem with this.  While PIPE_BUF is specified in a
kernel header, it ends up becoming an embedded value in glibc, from what
I can tell.  Which also makes it an embedded value in statically linked
apps.  This looks like a dead end, even for apps that use fpathconf().

Also, from looking at some of the kernel comments (like where PIPE_SIZE
is defined), it seems that the kernel powers-that-be also intend to keep
PIPE_BUF and PAGE_SIZE decoupled.

So the way forward seems to be to add a test to pipe_readv() for this
condition.

I'm thinking it should check if (PIPE_SIZE - buf->len) > PIPE_BUF, and
set do_wakeup.  The code could be #defined out if PIPE_SIZE = PIPE_BUF,
so the change reduces to a no-op on other archs.

Does that sound right?  I'm going to work on a patch here.

