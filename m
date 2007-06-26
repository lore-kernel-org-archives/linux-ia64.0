From: Robert Nagy <robert.nagy@gmail.com>
Date: Tue, 26 Jun 2007 19:16:38 +0000
Subject: Re: intercept trap when running a 32bit binary
Message-Id: <20070626191638.GA9452@bsd.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Unfortunately having steam.cfg is optional and it
does not change anything.

On (26/06/07 12:13), Luck, Tony wrote:
> > Here is the output http://humppa.hu/typescript
> 
> Nothing stands out there as totally off.  The program did open
> and read /proc/cpuinfo shortly before it died, so it might have
> found something that it didn't like in there (though it also read
> it just after startup without apparent ill effects).
> 
> Then at the very end it failed to open "steam.cfg" ... perhaps
> that was what it didn't like?
> 
> -Tony
