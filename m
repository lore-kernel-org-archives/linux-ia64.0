From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 16 Jan 2002 19:21:06 +0000
Subject: Re: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 16, 2002 at 11:15:57AM -0800, Michael Madore wrote:
> Stephane Eranian wrote:
> > 
> > Mike,
> > 
> > The problem is that the client side needs to know the size of the file
> > to allocate memory for it.  By default, the TFTP protocol has no
> > command to ask for the size of the file.  To work around the problem,
> > the client can load the file a few bytes at a time just to calculate
> > the size. Once the size is known, the allocation is done and the
> > file can be downloaded for real.
> 
> I noticed that the tftp server logged two requests for elilo.efi.  Does
> this look like a problem on the client or the server?

That is normal with a normal tftpd.  Note that you don't see this for the
kernel because elilo.efi uses an internal cache to avoid asking for the
file again.

>  
> > The ATFTP adds the support to ask for the file size, therefore you save
> > one download of the file. Note that elilo has the same thing when it
> > downloads any file from the network.
> 
> Is aftpd required?

No I don't run it and I netboot everyday. I use the tftpd shipped with RH7.2.

-- 
-Stephane

