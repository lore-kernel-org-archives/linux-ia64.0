From: n0ano@indstorage.com
Date: Tue, 16 Oct 2001 14:27:20 +0000
Subject: Re: [Linux-ia64] lost printk's
Message-Id: <marc-linux-ia64-105590698805350@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805347@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805347@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nathan-

I've used a Rocketport serial concentrator with a BigSur quite
successfully.  A single Rocketport PCI card can handle up to
32 ports.  I've never had an issue with 115200 baud, I set up
EFI to automatically boot Linux so I don't need to worry about
running EFI over the serial line and then just tell Linux to
run the serial line at 9600. 

On Tue, Oct 16, 2001 at 08:08:04AM -0500, Nathan Straz wrote:
> On Tue, Oct 16, 2001 at 04:47:26PM +1000, Keith Owens wrote:
> > If a crash kills the user space tasks or the disk I/O subsystem then
> > your printk does not get to disk.  Use a serial console and capture the
> > output on a second machine, that goes printk() -> console drivers ->
> > serial line.  
> 
> Can anyone recommend a console server that works well with Itanium
> machines?  The problem with most console servers (or inversely EFI) is
> that they don't run at 115200 baud.  Is everyone just running a line to
> another PC?  Is there a console server that can handle several of these
> machines?
> -- 
> Nate Straz                                              nstraz@sgi.com
> sgi, inc                                           http://www.sgi.com/
> Linux Test Project                                  http://ltp.sf.net/
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

