From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Mar 2003 02:14:25 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590723705354@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 28 Mar 2003 13:10:25 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Thu, 27 Mar 2003 17:53:05 -0800, 
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >>>>>>> On Fri, 28 Mar 2003 12:49:33 +1100, Keith Owens <kaos@sgi.com> said:
  >> 
  Keith> I am giving up on getting this patch into the community.  It will be
  Keith> applied to SGI ia64 kernels so they will be faster, smaller and have
  Keith> better debugging.  Community kernels will have to stay with the old
  Keith> code and inferior debugging for hung spinlocks.
  >> 
  >> Well, that's your right.  But please explain to me, just why is it so
  >> hard to bring up the issue with the ABI folks?  That would have taken
  >> less time than to argueing a moot point with me.

  Keith> Because I want to get on with kdb now!  Now after waiting for the ABI
  Keith> folks to get up to speed.  I am quite happy to talk to the ABI folks
  Keith> but not if it means delaying my improvements to kdb.  Put the code in
  Keith> and I will talk to the ABI folks, otherwise I am not going to bother.

Send a mail to the ABI folks now (and cc me) and I'll put in the
version that makes the new code available via a config option;
otherwise _I_ won't bother. ;-)

	--david

