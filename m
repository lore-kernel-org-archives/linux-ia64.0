From: Robin Holt <holt@sgi.com>
Date: Wed, 03 Mar 2004 13:40:51 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <20040303134051.GB24479@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 03, 2004 at 02:34:33PM +0100, Andreas Schwab wrote:
> Robin Holt <holt@sgi.com> writes:
> 
> > On Wed, Mar 03, 2004 at 11:57:21AM +0100, Andreas Schwab wrote:
> >> jbarnes@sgi.com (Jesse Barnes) writes:
> >> 
> >> > On Tue, Mar 02, 2004 at 06:56:55PM -0800, David Mosberger wrote:
> >> >> >>>>> On Wed, 03 Mar 2004 00:49:20 +0100, Andreas Schwab <schwab@suse.de> said:
> >> >> 
> >> >>   Andreas> Serial console output on Altix didn't convert NL to CRNL.
> >> >> 
> >> >> Somebody from SGI will have to review/OK this.
> >> >
> >> > Andreas, on which platform and configuration did you see this problem?
> >> 
> >> It's on the 8P Altix (can't remember the exact platform name).
> >> 
> >
> > Are you seeing the missing carriage return on output at the L1 or
> > on a terminal connected to the serial port?
> 
> I don't know how to differenciate between these two things.  The serial
> terminal is connected to the L1 system controller.

Are you connected via usb or a DB-9 serial connector?

Robin
