From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Mon, 05 Jan 2015 20:36:44 +0000
Subject: Re: status of ia64 / hpsim
Message-Id: <21674.62940.651019.548138@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
References: <20141230155057.GA23826@infradead.org>
	<CA+8MBbJgXAW5pgVk2zshR-09gDNXPDa__c+g5yxTt4wUrJGJ2Q@mail.gmail.com>
In-Reply-To: <CA+8MBbJgXAW5pgVk2zshR-09gDNXPDa__c+g5yxTt4wUrJGJ2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, mikpelinux@gmail.com, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Tony Luck writes:
 > On Tue, Dec 30, 2014 at 7:50 AM, Christoph Hellwig <hch@infradead.org> wrote:
 > > IS the ia64 hpsim architecture still in use?  I noticed it because it
 > > has a fairly rudimentary SCSI driver under arch/ia64, which doesn't
 > > look very maintained.
 > 
 > Mikael was doing something with hpsim on the ski simulator back in Jan'14. Was
 > that something real, or just playing because it was there?

I was trying to set up an emulated platform for continuous GCC bootstrap and
regression testsuite runs, but something broke the ia64 kernel causing EXT4
file system errors in the emulated platform, so I had to scrap that idea.

I tried various ia64 kernel versions, compiling the ia64 kernel with older
GCCs, and compiling SKI with older host (x86_64) GCCs, but nothing worked.
With no known-good starting point there was no reasonable way for me to
debug the problem.

/Mikael
