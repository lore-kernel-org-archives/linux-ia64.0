From: Jes Sorensen <jes@sunsite.dk>
Date: Tue, 31 Jul 2001 00:17:35 +0000
Subject: Re: [Linux-ia64] IA64 Linux issues
Message-Id: <marc-linux-ia64-105590693005961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005948@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005948@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Van" = Van Maren, Kevin <kevin.vanmaren@unisys.com> writes:

>>  I'd stay away from the qlogicfc.c driver, it's got all sorts of
>> limitations.
>> 
>> Jes

Van> Could you be more specific?  I have problems with the Adaptec as
Van> well (even after using the version with 39-bit DMA), and it
Van> [horrific I/O performance] doesn't appear to be a driver issue.

I can't remember all the details, but it includes bad error handling,
interrupt handling, lack of functionality.

Jes

