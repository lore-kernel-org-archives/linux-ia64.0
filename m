From: =?ISO-8859-1?Q?Anders_Herbj=F8rnsen?= <andersh@gar.no>
Date: Fri, 05 Apr 2002 14:02:43 +0000
Subject: Re: [Linux-ia64] pipe() not setting errno.
Message-Id: <marc-linux-ia64-105590701905391@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905376@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905376@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Reply to the message of Thursday April 4, 2002 15:36 +0100
-----------------------------------------------------------------
Andreas Schwab <schwab@suse.de internet> writes:

|> When running out of file descriptors pipe() does return -1 but
|> errno is not set. This is working ok on IA32 systems, but fails
|> on IA64. I've tested this with kernels 2.4.9 and 2.4.18.

>It's a bug in glibc, this should fix it:

Thanks, the patch worked like charm!

Anders

