From: Nathan Scott <nathans@sgi.com>
Date: Fri, 10 Oct 2003 02:22:19 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106575273205333@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 09, 2003 at 01:46:56PM -0700, David Mosberger wrote:
>   Nathan> I'm not surprised, and I can understand your position.  I'll
>   Nathan> come back to do an audit when I can, if noone beats me to it
>   Nathan> in the meantime.
> 
> I doubt anyone will beat you to it.  I don't think the audit should
> take a huge amount of time.  Perhaps half to a full day, just to make
> sure we're not missing something subtle (such as ioctl()s or something
> like that).

I've started the audit, but I'm not finished yet & gotta run
(short vacation, sorry wife says no laptop allowed).  I think
I have found two possible issues, I will send out an updated
patch next week.

cheers.

-- 
Nathan
