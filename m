From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Sun, 02 Nov 2003 13:33:36 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106778044630283@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We already have that interface, it is called a signal.  The kernel code
> for handling these events has to be architecture dependent but, once
> the data has been gathered and the decision made about which user
> process to kill, we just send SEGV.

:-) I think there is more to it, for example we should avoid 
re-allocating a page which has a hard error to make sure that the next
user stumbles over this again. Maybe this information should also be
kept accross a reboot for the same reason. Then you need some API to maintain
this information, if for example a DIMM is replaced and it is not longer
require to map out a page with an error. 


Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

