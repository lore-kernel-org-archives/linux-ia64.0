From: Keith Owens <kaos@sgi.com>
Date: Fri, 28 Mar 2003 02:10:25 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590723705353@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 27 Mar 2003 17:53:05 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 28 Mar 2003 12:49:33 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> I am giving up on getting this patch into the community.  It will be
>  Keith> applied to SGI ia64 kernels so they will be faster, smaller and have
>  Keith> better debugging.  Community kernels will have to stay with the old
>  Keith> code and inferior debugging for hung spinlocks.
>
>Well, that's your right.  But please explain to me, just why is it so
>hard to bring up the issue with the ABI folks?  That would have taken
>less time than to argueing a moot point with me.

Because I want to get on with kdb now!  Now after waiting for the ABI
folks to get up to speed.  I am quite happy to talk to the ABI folks
but not if it means delaying my improvements to kdb.  Put the code in
and I will talk to the ABI folks, otherwise I am not going to bother.


