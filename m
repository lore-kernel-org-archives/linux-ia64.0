From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Thu, 06 Nov 2003 14:23:05 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106812960922772@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I want to check some in MCA recovery.
> Here is some steps, roughly say:

One of the complexities is recovery on a large-scale system, if for
example, multiple CPUs access a poisoned memory location at the same time.

Other "interesting" errors scenarious are if data is DEX with bad ECC in CPU 
A's cache and CPU B requests the line from CPU A. 

>  - Interruption must be synchronized.

I'm not sure what you mean by this.


Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

