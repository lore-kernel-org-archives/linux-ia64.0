From: Christoph Lameter <christoph@lameter.com>
Date: Sat, 17 Jul 2004 16:50:28 +0000
Subject: Re: final [hopefully] timer patches
Message-Id: <Pine.LNX.4.58.0407170947210.1456@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407161057440.29976@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407161057440.29976@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 16 Jul 2004, David Mosberger wrote:

> The fsys.S portion of the patch still doesn't apply.  I think that's
> because your missing Ken's fix for fsys_gettimeofday() that went in
> recently.

The patch is against 2.6.8-rc1 which does not contain Ken's patch. I can
make a patch against your tree if you think its ready to get in.

> Also, it would be good if the common code for fsys_gettimeofday() and
> fsys_clock_get() could be factored (into a macro, probably, since you
> can't use the standard calling convention without switching to kernel
> stacks first).

Doing so is quite an unusual approach. I thought it was better to leave
things the way it is. I tried doing a subroutine but that resulted in a
lot of complications with saving state.


