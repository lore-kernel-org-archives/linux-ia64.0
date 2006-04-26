From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 26 Apr 2006 15:53:53 +0000
Subject: Re: I/O read, write implementation questions
Message-Id: <20060426105259.L18889@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444E2EA6.8000604@bull.net>
In-Reply-To: <444E2EA6.8000604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 26 Apr 2006, Brent Casavant wrote:

> Note that wmb() is not sufficient for writes, at least on SGI Altix.
> wmb() ensures that the write has issued from the processor, however
> it does not ensure that the I/O device itself has seen the write.
> The mmiowb() is the appropriate call to ensure that the write has
> been seen.

Oh, and lest I confuse anyone, wmb() is sufficient for writes to RAM.
It's only I/O writes for which it is insufficient.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
