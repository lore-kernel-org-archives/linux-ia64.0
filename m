From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 03 Mar 2004 17:19:37 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <20040303171936.GC2026@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 03, 2004 at 11:57:21AM +0100, Andreas Schwab wrote:
> The system controller should not change the output in any way.  It's the
> job of the serial console write function (which is used for printk) to

Right, but I think our L2 system controller *does* molest the output
(and the 2.6 console driver relies on this behavior).  I've filed a bug
with our system controller group to make the behavior of the L2 and L1
system controllers consistent (I believe you're using an L1), which I
think is the proper fix.

Thanks,
Jesse
