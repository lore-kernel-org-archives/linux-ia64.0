From: Bill Nottingham <notting@redhat.com>
Date: Thu, 24 May 2001 21:56:40 +0000
Subject: [Linux-ia64] Re: EFI GPT tools ?
Message-Id: <marc-linux-ia64-105590693005672@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005581@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005581@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill Nottingham (notting@redhat.com) said: 
> McCaffity, Ray (ray.mccaffity@wcg.com) said: 
> > I guess I'm not really sure what GPT is, but is there any IA64
> > support journaled file systems yet?  (ReiserFS or JFS, etc..)
> > If this is the parted tool for partitioning, I have used that
> > on x86, but doesn't appear to support anything but ext2.
> 
> I tried reiserfs once, it did not work *at all*. I keep meaning
> to try it again, but I haven't got around to it.

I checked again; with reiserfs you can create & mount filesystems,
and copy data onto them, but if you try and read a directory,
you get unaligned accesses in the kernel, and you can't see any
files/directories.

Bill

