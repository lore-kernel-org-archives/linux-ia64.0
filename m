From: Martin Pool <mbp@samba.org>
Date: Wed, 14 May 2003 02:14:21 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705770@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 13 May 2003, Bruno Vidal <bruno_vidal@hp.com> wrote:
> 	Hi
> Sorry, but LKCD is really not usefull because it use the buffer
> to write on the device. So it just hang in case of data page fault for
> example (because interuption are masked), LKCD is also not working in case
> of buffer corruption, disk driver pb, etc.... so LKCD is not usable in
> lot's of case (and it happen really often to have data page fault).

There is also the netconsole/netdump system.  This is supposed to rely
on only a very minimal network driver.  As you say, writing to disk
when kernel memory may have been corrupted is a risky business, not
only because you might hang but also because you might write over the
wrong region.  netdump doesn't do any disk IO for that reason.  I seem
to recall that Linus liked this property.

Of course it's only useful if the machine is on a network where there
is another machine to catch the data, but I would expect that to be
the case for most ia64 machines.

  http://www.redhat.com/support/wpapers/redhat/netdump/

-- 
Martin 

