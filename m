From: Robin Holt <holt@sgi.com>
Date: Wed, 03 Mar 2004 15:11:18 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <20040303151118.GA29598@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 03, 2004 at 03:20:46PM +0100, Andreas Schwab wrote:
> Robin Holt <holt@sgi.com> writes:
> 
> > Are you connected via usb or a DB-9 serial connector?
> 
> DB-9, I think.

The last time I connected to the DB-9 on the back of an Altix,
I was using minicom (I think) and just changed it so it
would interpret LF as CRLF.  I seem to remember something
like LF <--> CRLF on the line.  Don't remember if that was
exactly what it looked like.

Is this something that should really be done by the terminal
and not the serial driver?  I don't have any objections
either way, but I would guess we would want to stay as
close to whatever x86 linux is doing.  I plead ignorance at
this point.

Robin
