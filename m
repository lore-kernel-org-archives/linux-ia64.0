From: martin sepulveda <martin@ojf.com>
Date: Thu, 17 Apr 2003 23:57:06 +0000
Subject: Re: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

we did a little shell script to watch kernel messages and do a 'ps ax' on the pid,
and saw oracle proceses were not running after the message was printk'ed 
(at least not for much time).
the floating-poin assist fault was only trigered by oracle processes, but oracle 
was the only heavily used on this machines during the test.
by the way it happens on all four nodes we're running, the firmware is up to date
and includes the FPSWA, but it might be affected by system load, since in some
cases it would be affecting about 10 % of the oracle processes while on other
tests it may be seen affecting below 1%.

(i'm not on the list)

m.

On Thu, 17 Apr 2003 13:40:28 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> > Sometimes the Oracle process dies with the following error message:
> > 
> > Apr 17 20:24:48 rx1 kernel: oracle(7148): floating-point assist fault at ip 40000000048b4562
> > 
> > The ip address is always the same. This happens on all of our 4 nodes
> > as it seems randomly. I do not have other debug info as this is the only
> > message printed. Some times for the same process the message is printed 
> > up to 4 times.
> 
> Are you certain that the message is related to the death of the process?
> 
> This message is a warning to let you know that your application has run into
> one of the corner cases of IEEE floating point that is not implemented in
> hardware by the processor (typically operations involving denormalized numbers
> will cause this, but there may be other cases). There is rate limiting code in
> the kernel to prevent this message from flooding the logs (and from becoming
> even more of a performance drag than taking a trap and emulating in s/w).
> 
> It is relatively normal to see this message (even multiple times from the
> same process), and it usually isn't fatal.
> 
> -Tony Luck
> 

