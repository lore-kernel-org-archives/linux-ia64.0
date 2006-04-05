From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 05 Apr 2006 16:17:06 +0000
Subject: Re: Fix ia64 bit ops: Full barriers for bit operations returning a
Message-Id: <Pine.LNX.4.64.0604050916020.1387@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 4 Apr 2006, Zoltan Menyhart wrote:

> Christoph Lameter wrote:
> 
> > Could you come up with a patch? Currently, I do not seem to be able to spend
> > enough time on it.
> 
> Please have a look at this sample.

Could decomplicate this? Just use acquire / release and avoid the 
additional intrinsics. The purpose is first of all correctness. Then we 
can add some whiz bang on top. Also please sent patches inline not as 
attachments.

