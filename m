From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 12 May 2004 21:24:42 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405121424.42415.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, May 12, 2004 2:11 pm, David Mosberger wrote:
> So if multiple processes map the same I/O range then _all_ of them
> will be terminated?

As it stands, only the first PID that has a matching range will get a SIGBUS, 
but that could be changed.

> What if stuff gets remapped etc?

Then the machine takes an unrecoverable MCA, just like it does now.

> This all just seems incredibly fragile to me.

I think it's useful for at least a subset of the I/O MCAs that people see, and 
with the addition of the read_check stuff, may be more generally useful.  
Obviously though, this doesn't recover from 100% of I/O errors, something 
that's probably not practical anyway...

Jesse
