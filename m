From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 03 Mar 2004 03:31:28 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <20040303033128.GA31005@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 02, 2004 at 06:56:55PM -0800, David Mosberger wrote:
> >>>>> On Wed, 03 Mar 2004 00:49:20 +0100, Andreas Schwab <schwab@suse.de> said:
> 
>   Andreas> Serial console output on Altix didn't convert NL to CRNL.
> 
> Somebody from SGI will have to review/OK this.

Andreas, on which platform and configuration did you see this problem?
It appears that depending on your console configuration, the system
controller will eat/convert characters.  I'm trying to get it fixed
properly there...

Jesse
