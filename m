From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 23 May 2001 22:26:28 +0000
Subject: Re: [Linux-ia64] 2.4.4 stability on Lions
Message-Id: <marc-linux-ia64-105590693005665@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005642@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005642@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Unfortunately, this is for an install CD, so I can't statically link in a
driver.

On Wed, May 23, 2001 at 02:54:30PM -0700, Robboy, David G wrote:
> > 
> > Thanks Asit.  Is there a way to temporarily disable the on 
> > board NIC?  Our
> > installer always defaults to eth0 for network installs.  As 
> > luck would have
> > it, the e100 modules get loaded before our add in 3com.
> 
> If you build a kernel with the 3com driver linked in (not a module), and
> don't configure in the e100, it should work.  I just did that with a Tulip
> card and it's working.
> 
> David

-- 
Mike Madore
Senior Software Engineer
TurboLinux, Inc.
(650)228-5203

