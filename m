From: Grant Grundler <iod00d@hp.com>
Date: Fri, 16 Jan 2004 05:50:31 +0000
Subject: Re: [PATCH] readX_relaxed interface
Message-Id: <20040116055031.GD13222@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040115204913.GA8172@sgi.com> <20040116003224.GF23253@kroah.com>
In-Reply-To: <20040116003224.GF23253@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Jesse Barnes <jbarnes@sgi.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeremy@sgi.com

On Thu, Jan 15, 2004 at 04:32:25PM -0800, Greg KH wrote:
[ deleted reminder for readb() to return success/fail codes ]
> Just wanted to put this idea in people's heads that we need to start
> planning for something like it.

I just remembered another part of linux 2.4/2.6 that needs revisiting:
DMA mapping routines don't return an error code.
ie pci_map_single() must panic since it can't return a failure.
It was designed that way on purpose to make life easier for driver
writers (and I agree, it has).

(my guess is x86-64 needs this change more urgently than any other arch.)

I'm sure there are other robustness issues too.
Looking for "panic" will probably give alot of them away.
The current 2.6.1 tree has over 1000 panic() calls.
I used "find -name \*.c | fgrep panic\( | wc ".

And for my amusement:
grundler <506>find drivers/scsi -name \*.c | xargs fgrep panic\( | wc
    183    1243   14722
grundler <507>find drivers/net -name \*.c | xargs fgrep panic\( | wc
     10      53     662

My point is a substantial number of things can be done to improve
robustness besides (or in addition to?) recovering from IO subsystem
crashes.

grant
