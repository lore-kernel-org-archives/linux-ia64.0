From: Michael Brown <Michael_E_Brown@Dell.com>
Date: Sun, 06 Jun 2004 00:07:59 +0000
Subject: Re: EFI-support for SMBIOS driver
Message-Id: <1086480479.15687.12854.camel@debian>
List-Id: <linux-ia64.vger.kernel.org>
References: <16577.6469.833064.763671@napali.hpl.hp.com>
	 <20040605032902.GA7069@kroah.com>
	 <16577.17064.857172.598873@napali.hpl.hp.com>
In-Reply-To: <16577.17064.857172.598873@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Sorry David.

I was the original submitter. Somebody kindly pointed out to me
(offline) the error of my ways, and I was able to get my userspace lib
to work just fine using mmap() instead of read(). This takes care of two
out of three of the main reasons I orignally submitted this driver.

Since my library was the only user of this lib, and I no longer need it,
I asked several people if it would make sense to continue to support it
or to pull it. The consensus was not to "bloat" the kernel with extra
stuff if it can be done via /dev/mem.

If there are strong sentiments the other way, the code is still out
there if somebody else wants to take over. I looked at what it would
take to add EFI support for this, and it would be trivial. I just didn't
want to become yet another absentee-maintainer if I no longer need the
code. 
--
Michael Brown

On Fri, 2004-06-04 at 22:48, David Mosberger wrote:
> >>>>> On Fri, 4 Jun 2004 20:29:02 -0700, Greg KH <greg@kroah.com> said:
> 
>   Greg> On Fri, Jun 04, 2004 at 05:52:21PM -0700, David Mosberger
>   Greg> wrote:
> 
>   >> The patch below adds EFI support to the SMBIOS driver.
> 
>   Greg> The smbios driver is gone in 2.6.7-rc.  You don't need a
>   Greg> driver for this, as you can do everything from userspace.
> 
> I know full well that it can be done in user-level --- via /dev/mem,
> which lots of people dislike.  I certainly don't feel strongly about
> it, but the SMBIOS driver made sense to me.
> 
> 	--david

