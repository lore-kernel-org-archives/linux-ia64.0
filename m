From: Jiri Slaby <jirislaby@kernel.org>
Date: Mon, 07 Feb 2022 05:38:16 +0000
Subject: Re: [PATCH v2 3/3] vstatus: Display an informational message when the VSTATUS character is pressed o
Message-Id: <35f29dbd-04ec-037e-007c-7a079caf0d5b@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220206154856.2355838-1-walt@drummond.us>
 <20220206154856.2355838-4-walt@drummond.us>
In-Reply-To: <20220206154856.2355838-4-walt@drummond.us>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Walt Drummond <walt@drummond.us>, agordeev@linux.ibm.com, arnd@arndb.de, benh@kernel.crashing.org, borntraeger@de.ibm.com, chris@zankel.net, davem@davemloft.net, gregkh@linuxfoundation.org, hca@linux.ibm.com, deller@gmx.de, ink@jurassic.park.msu.ru, James.Bottomley@HansenPartnership.com, mattst88@gmail.com, jcmvbkbc@gmail.com, mpe@ellerman.id.au, paulus@samba.org, rth@twiddle.net, dalias@libc.org, tsbogend@alpha.franken.de, gor@linux.ibm.com, ysato@users.osdn.me
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, ar@cs.msu.ru, linuxppc-dev@lists.ozlabs.org

On 06. 02. 22, 16:48, Walt Drummond wrote:
> When triggered by pressing the VSTATUS key or calling the TIOCSTAT
> ioctl, the n_tty line discipline will display a message on the user's
> tty that provides basic information about the system and an
> 'interesting' process in the current foreground process group, eg:
> 
>    load: 0.58  cmd: sleep 744474 [sleeping] 0.36r 0.00u 0.00s 0% 772k
> 
> The status message provides:
>   - System load average
>   - Command name and process id (from the perspective of the session)
>   - Scheduler state
>   - Total wall-clock run time
>   - User space run time
>   - System space run time
>   - Percentage of on-cpu time
>   - Resident set size
> 
> The message is only displayed when the tty has the VSTATUS character
> set, the local flags ICANON and IEXTEN are enabled and NOKERNINFO is
> disabled; it is always displayed when TIOCSTAT is called regardless of
> tty settings.
> 
> Signed-off-by: Walt Drummond <walt@drummond.us>
> ---

It looks like my comments were addressed. However you did not document 
the chances since v1 here. IOW, [v2] tag missing here.

And please add the CCs I added last time, so that relevant people still 
can comment.

thanks,
-- 
js
suse labs
