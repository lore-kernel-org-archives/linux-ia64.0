From: n0ano@indstorage.com
Date: Fri, 19 Oct 2001 17:46:45 +0000
Subject: Re: [Linux-ia64] Driver development document
Message-Id: <marc-linux-ia64-105590698805373@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805372@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805372@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gururaj-

The same document that explains how to write IA32 drivers :-)

Seriously, all of the kernel interfaces you should need should
be the same between IA32 and IA64.  It's amazing how many IA64
drivers were created by just re-compiling the IA32 versiion with
no source code changes.

I would recommend starting with the book `Linux Device Drivers'
by Rubini.  It's kind of out of date (written for the 2.0 kernel)
but it gives you a good idea about the basics.

On Fri, Oct 19, 2001 at 10:00:13AM -0700, Gururaj Ananthateerta wrote:
> I am newbie to Linux.
> Is there any document which explains howto write linux network drivers for
> ia-64.?
> 
> Thanks
> 
> 
> 
> 
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

